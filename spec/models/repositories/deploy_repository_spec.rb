require 'rails_helper'

RSpec.describe Repositories::DeployRepository do
  subject(:repository) { Repositories::DeployRepository.new }

  describe '#deploys_for' do
    context 'when no apps are specified' do
      it 'returns deploys for all apps to that server' do
        create(:deploy_event, server: 'ex.io', version: '1', app_name: 'ap1', deployed_by: 'dj')
        create(:deploy_event, server: 'ex.io', version: '2', app_name: 'ap2', deployed_by: 'dj')
        create(:deploy_event, server: 'other.io', version: '3', app_name: 'ap3', deployed_by: 'dj')

        repository.update

        results = repository.deploys_for(server: 'ex.io')

        expect(results[:deploys]).to match_array([
          Deploy.new(app_name: 'ap1', server: 'ex.io', version: '1', deployed_by: 'dj', correct: false),
          Deploy.new(app_name: 'ap2', server: 'ex.io', version: '2', deployed_by: 'dj', correct: false),
        ])
      end
    end

    context 'before an update' do
      it 'returns the state for the apps and server referenced' do
        events = [create(:deploy_event), create(:deploy_event), create(:deploy_event), create(:deploy_event)]

        results = repository.deploys_for(
          apps: {
            'ap1' => 'abc',
            'ap2' => 'ghi',
          },
          server: 'ex.io',
        )

        expect(results[:deploys]).to eq([])
        expect(results[:events].to_a).to eq(events)
      end
    end

    context 'after an update' do
      it 'returns the state for the apps and server referenced' do
        create(:deploy_event, server: 'ex.io', version: 'abc', app_name: 'ap1', deployed_by: 'dj')
        create(:deploy_event, server: 'example.com', version: 'xxx', app_name: 'ap1', deployed_by: 'dj')
        create(:deploy_event, server: 'ex.io', version: 'def', app_name: 'ap2', deployed_by: 'dj')
        create(:deploy_event, server: 'ex.io', version: 'ghi', app_name: 'ap1', deployed_by: 'dj')

        repository.update

        result = repository.deploys_for(
          apps: {
            'ap1' => 'abc',
            'ap2' => 'def',
          },
          server: 'ex.io',
        )

        expect(result[:deploys]).to contain_exactly(
          Deploy.new(app_name: 'ap1', server: 'ex.io', version: 'ghi', deployed_by: 'dj', correct: false),
          Deploy.new(app_name: 'ap2', server: 'ex.io', version: 'def', deployed_by: 'dj', correct: true),
        )
        expect(result[:events].to_a).to eq([])
      end
    end

    context 'with at specified' do
      it 'returns the state at that moment' do
        defaults = { server: 'ex.io', deployed_by: 'dj' }

        create(:deploy_event, defaults.merge(version: 'abc', app_name: 'ap1', created_at: 3.hours.ago))
        create(:deploy_event, defaults.merge(server: 'foo.com', app_name: 'ap1', created_at: 2.hours.ago))
        create(:deploy_event, defaults.merge(version: 'def', app_name: 'ap2', created_at: 1.hours.ago))
        create(:deploy_event, defaults.merge(version: 'ghi', app_name: 'ap1', created_at: Time.current))

        repository.update

        result = repository.deploys_for(
          apps: {
            'ap1' => 'abc',
            'ap2' => 'def',
          },
          server: 'ex.io',
          at: 2.hours.ago,
        )

        expect(result[:deploys]).to contain_exactly(
          Deploy.new(app_name: 'ap1', server: 'ex.io', version: 'abc', deployed_by: 'dj', correct: true),
        )
        expect(result[:events].to_a).to eq([])
      end
    end

    context 'with at specified but repository not up-to-date' do
      it 'returns the state at that moment and new events up to that moment' do
        defaults = { server: 'ex.io', deployed_by: 'dj' }

        create(:deploy_event, defaults.merge(version: '1', app_name: 'ap1', created_at: 3.hours.ago))

        repository.update

        expected_event =
          create(:deploy_event, defaults.merge(version: '2', app_name: 'ap1', created_at: 2.hours.ago))
        create(:deploy_event, defaults.merge(version: '3', app_name: 'ap1', created_at: 1.minute.ago))

        result = repository.deploys_for(
          apps: { 'ap1' => '2' },
          server: 'ex.io',
          at: 1.hour.ago,
        )

        expect(result[:deploys]).to contain_exactly(
          Deploy.new(app_name: 'ap1', server: 'ex.io', version: '1', deployed_by: 'dj', correct: false),
        )
        expect(result[:events].to_a).to eq([expected_event])
      end
    end
  end
end
