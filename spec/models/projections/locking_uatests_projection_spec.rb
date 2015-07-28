require 'rails_helper'
require 'support/shared_examples/locking_projection_examples'

RSpec.describe Projections::LockingUatestsProjection do
  let(:apps) { { 'frontend' => 'abc' } }
  let(:server) { 'uat.fundingcircle.com' }

  let(:projection_url) { feature_review_url(apps, server) }
  let(:feature_review_location) { FeatureReviewLocation.new(projection_url) }

  let(:defaults) { { success: true, test_suite_version: '111', server: server } }

  subject(:projection) {
    Projections::LockingUatestsProjection.new(feature_review_location)
  }

  it_behaves_like 'a locking projection' do
    before do
      projection.apply(build(:deploy_event, server: server, version: 'abc', app_name: 'frontend'))
    end

    context 'when no locking occurs' do
      it 'projects last UaTest' do
        projection.apply(build(:uat_event, defaults))
        expect(projection.uatest).to eq(Uatest.new(defaults))

        projection.apply(build(:uat_event, defaults.merge(test_suite_version: '999')))
        expect(projection.uatest).to eq(Uatest.new(defaults.merge(test_suite_version: '999')))
      end
    end

    context 'when it becomes locked' do
      it 'projects the last UaTest before it became locked' do
        expected_qa_submission = Uatest.new(defaults)

        projection.apply(build(:uat_event, defaults))
        expect(projection.uatest).to eq(expected_qa_submission)

        projection.apply(lock_event)
        expect(projection.uatest).to eq(expected_qa_submission)

        projection.apply(build(:uat_event, defaults.merge(test_suite_version: '999')))
        expect(projection.uatest).to eq(expected_qa_submission)
      end
    end

    context 'when it becomes unlocked' do
      it 'projects the last UaTest' do
        projection.apply(build(:uat_event, defaults))
        projection.apply(lock_event)
        projection.apply(build(:uat_event, defaults.merge(test_suite_version: '999')))
        projection.apply(unlock_event)

        expect(projection.uatest).to eq(Uatest.new(defaults.merge(test_suite_version: '999')))
      end
    end
  end

  context 'when the server matches' do
    context 'when the app versions match' do
      let(:apps) { { 'frontend' => 'abc', 'backend' => 'def' } }

      before do
        projection.apply(build(:deploy_event, server: server, app_name: 'frontend', version: 'old'))
        projection.apply(build(:deploy_event, server: server, app_name: 'frontend', version: 'abc'))
        projection.apply(build(:deploy_event, server: server, app_name: 'backend', version: 'def'))
      end

      it 'returns the relevant User Acceptance Tests details' do
        projection.apply(build(:uat_event, test_suite_version: 'xyz', success: true, server: server))
        projection.apply(build(:jira_event))
        expect(projection.uatest).to eq(Uatest.new(success: true, test_suite_version: 'xyz'))

        projection.apply(build(:uat_event, test_suite_version: 'xyz', success: false, server: server))
        expect(projection.uatest).to eq(Uatest.new(success: false, test_suite_version: 'xyz'))
      end
    end

    context 'when some of the app versions match' do
      let(:apps) { { 'frontend' => 'abc', 'backend' => 'def' } }

      before do
        projection.apply(build(:deploy_event, server: server, app_name: 'frontend', version: 'abc'))
        projection.apply(build(:deploy_event, server: server, app_name: 'backend', version: 'not_def'))
      end

      it 'ignores the UAT event' do
        uat_event = build(:uat_event, server: server)

        projection.apply(uat_event)

        expect(projection.uatest).to be nil
      end
    end

    context 'when all the app versions do not match' do
      let(:apps) { { 'frontend' => 'abc', 'backend' => 'def' } }

      before do
        projection.apply(build(:deploy_event, server: server, app_name: 'frontend', version: 'not_abc'))
        projection.apply(build(:deploy_event, server: server, app_name: 'backend', version: 'not_def'))
      end

      it 'ignores the UAT event' do
        uat_event = build(:uat_event, server: server)

        projection.apply(uat_event)

        expect(projection.uatest).to be nil
      end
    end

    context 'when a deploy event does not exist for all apps' do
      it 'ignores the UAT event' do
        projection.apply(build(:uat_event, server: server))

        expect(projection.uatest).to be nil
      end
    end
  end

  context 'when the server does not match' do
    before do
      projection.apply(build(:deploy_event, server: server, app_name: 'frontend', version: 'abc'))
    end

    it 'ignores the UAT event' do
      projection.apply(build(:uat_event, server: 'other.server'))
      expect(projection.uatest).to be nil
    end
  end

  context 'when we receive deploy events for different servers' do
    it 'does not affect the result' do
      projection.apply(build(:deploy_event, server: server, app_name: 'frontend', version: 'abc'))
      projection.apply(build(:deploy_event, server: 'other.server', app_name: 'frontend', version: 'zzz'))
      projection.apply(build(:uat_event, server: server))

      expect(projection.uatest).to be_present
    end
  end
end
