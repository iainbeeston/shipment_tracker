require 'rails_helper'

RSpec.describe Projections::UatestsProjection do
  let(:apps) { { 'frontend' => 'abc' } }
  let(:server) { 'uat.fundingcircle.com' }

  let(:defaults) { { success: true, test_suite_version: '111', server: server } }

  subject(:projection) { Projections::UatestsProjection.new(apps: apps, server: server) }

  describe '.load' do
    let(:repository) { instance_double(Repositories::UatestRepository) }
    let(:expected_uatest) { Uatest.new }
    let(:expected_versions) { { app_name: 'abc' } }
    let(:expected_events) { [Event.new] }
    let(:expected_projection) { instance_double(Projections::UatestsProjection) }
    let(:time) { Time.current }

    it 'inflates the projection and feeds it remaining events' do
      allow(repository).to receive(:uatest_for)
        .with(apps: apps, server: server, at: time)
        .and_return(
          uatest: expected_uatest,
          versions: expected_versions,
          events: expected_events,
        )

      allow(Projections::UatestsProjection).to receive(:new).with(
        apps: apps,
        server: server,
        versions: expected_versions,
        uatest: expected_uatest,
      ).and_return(expected_projection)

      expect(expected_projection).to receive(:apply_all).with(expected_events)

      expect(
        Projections::UatestsProjection.load(apps: apps, server: server, at: time, repository: repository),
      ).to be(expected_projection)
    end
  end

  it 'projects last UaTest' do
    projection.apply(build(:deploy_event, server: server, version: 'abc', app_name: 'frontend'))
    projection.apply(build(:uat_event, defaults))
    expect(projection.uatest).to eq(Uatest.new(defaults))

    projection.apply(build(:uat_event, defaults.merge(test_suite_version: '999')))
    expect(projection.uatest).to eq(Uatest.new(defaults.merge(test_suite_version: '999')))
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
