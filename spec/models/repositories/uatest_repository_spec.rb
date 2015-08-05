require 'rails_helper'

RSpec.describe Repositories::UatestRepository do
  let(:deploy_projection_loader) { class_double(Projections::DeploysProjection) }

  subject(:repository) { Repositories::UatestRepository.new(deploy_projection: deploy_projection_loader) }

  describe '#uatest_for' do
    let(:apps) { { 'a' => '1' } }
    let(:server) { 'uat.example.com' }

    context 'before an update' do
      it 'returns the state for the apps and server referenced' do
        events = [create(:deploy_event), create(:uat_event), create(:uat_event)]

        results = repository.uatest_for(apps: apps, server: server)

        expect(results[:uatest]).to be_nil
        expect(results[:versions]).to eq({})
        expect(results[:events].to_a).to eq(events)
      end
    end

    context 'after an update' do
      it 'returns the state for the apps and server referenced' do
        times = [1.hour.ago, 1.minute.ago].map { |t| t.change(usec: 0) }

        deploy_0 = Deploy.new(app_name: 'a', version: '0', server: server)

        allow(deploy_projection_loader).to receive(:load)
          .with(server: server, at: times[0])
          .and_return(instance_double(Projections::DeploysProjection, deploys: [deploy_0]))

        deploy_1 = Deploy.new(app_name: 'a', version: '1', server: server)
        deploy_2 = Deploy.new(app_name: 'b', version: '2', server: server)

        allow(deploy_projection_loader).to receive(:load)
          .with(server: server, at: times[1])
          .and_return(instance_double(Projections::DeploysProjection, deploys: [deploy_1, deploy_2]))

        create(:uat_event, test_suite_version: '1', server: server, success: true, created_at: times[0])
        create(:uat_event, test_suite_version: '2', server: server, success: true, created_at: times[1])

        repository.update

        result = repository.uatest_for(apps: apps, server: server)

        expect(result[:uatest]).to eq(Uatest.new(success: true, test_suite_version: '2'))
        expect(result[:versions]).to eq('a' => '1', 'b' => '2')
        expect(result[:events].to_a).to eq([])
      end
    end

    context 'with at specified' do
      it 'returns the state at that moment' do
        times = [5.hours.ago, 4.hours.ago, 3.hours.ago, 2.hours.ago, 1.hour.ago].map { |t| t.change(usec: 0) }

        deploy = Deploy.new(app_name: 'a', version: '1', server: server)

        allow(deploy_projection_loader).to receive(:load)
          .with(server: server, at: times[0])
          .and_return(instance_double(Projections::DeploysProjection, deploys: [deploy]))

        allow(deploy_projection_loader).to receive(:load)
          .with(server: 'other', at: times[0])
          .and_return(instance_double(Projections::DeploysProjection, deploys: []))

        allow(deploy_projection_loader).to receive(:load)
          .with(server: server, at: times[1])
          .and_return(instance_double(Projections::DeploysProjection, deploys: [deploy]))

        create(:uat_event, test_suite_version: '1', server: server, success: false, created_at: times[0])
        create(:uat_event, test_suite_version: '1', server: 'other', success: true, created_at: times[0])
        create(:uat_event, test_suite_version: '2', server: server, success: true, created_at: times[1])

        repository.update

        result = repository.uatest_for(apps: apps, server: server, at: times[0])

        expect(result[:uatest]).to eq(Uatest.new(success: false, test_suite_version: '1'))
        expect(result[:versions]).to eq('a' => '1')
        expect(result[:events].to_a).to eq([])
      end
    end

    context 'with at specified but repository not up-to-date' do
      it 'returns the state at that moment and new events up to that moment' do
        deploy_projection = instance_double(
          Projections::DeploysProjection,
          deploys: [Deploy.new(app_name: 'a', version: '1', server: server)],
        )

        allow(deploy_projection_loader).to receive(:load)
          .with(server: server, at: anything)
          .and_return(deploy_projection)

        defaults = { success: false, server: server }

        t = [3.hours.ago, 2.hours.ago, 1.minute.ago]

        create(:uat_event, defaults.merge(test_suite_version: '1', success: true, created_at: t[0]))

        repository.update

        expected_event = create(:uat_event, defaults.merge(test_suite_version: '2', created_at: t[1]))
        create(:uat_event, defaults.merge(test_suite_version: '3', created_at: t[2]))

        result = repository.uatest_for(apps: apps, server: server, at: t[1])

        expect(result[:uatest]).to eq(Uatest.new(success: true, test_suite_version: '1'))
        expect(result[:versions]).to eq('a' => '1')
        expect(result[:events].to_a).to eq([expected_event])
      end
    end
  end
end
