require 'rails_helper'

RSpec.describe UatestsProjection do
  let(:apps) { { 'frontend' => 'abc', 'backend' => 'def' } }
  let(:server) { 'uat.fundingcircle.com' }

  subject(:projection) { UatestsProjection.new(apps: apps, server: server) }

  context 'when the server matches' do
    context 'when the app versions match' do
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
      before do
        projection.apply(build(:deploy_event, server: server, app_name: 'frontend', version: 'abc'))
      end

      it 'ignores the UAT event' do
        projection.apply(build(:uat_event, server: server))

        expect(projection.uatest).to be nil
      end
    end
  end

  context 'when the server does not match' do
    before do
      projection.apply(build(:deploy_event, server: server, app_name: 'frontend', version: 'abc'))
      projection.apply(build(:deploy_event, server: server, app_name: 'backend', version: 'def'))
    end

    it 'ignores the UAT event' do
      projection.apply(build(:uat_event, server: 'other.server'))
      expect(projection.uatest).to be nil
    end
  end

  context 'when we receive deploy events for different servers' do
    it 'does not affect the result' do
      projection.apply(build(:deploy_event, server: server, app_name: 'frontend', version: 'abc'))
      projection.apply(build(:deploy_event, server: server, app_name: 'backend', version: 'def'))
      projection.apply(build(:deploy_event, server: 'other.server', app_name: 'frontend', version: 'zzz'))
      projection.apply(build(:uat_event, server: server))

      expect(projection.uatest).to be_present
    end
  end
end
