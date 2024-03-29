require 'rails_helper'

RSpec.describe Repositories::DeployRepository do
  subject(:repository) { Repositories::DeployRepository.new }

  describe '#table_name' do
    let(:active_record_class) { class_double(Snapshots::Deploy, table_name: 'the_table_name') }

    subject(:repository) { Repositories::DeployRepository.new(active_record_class) }

    it 'delegates to the active record class backing the repository' do
      expect(repository.table_name).to eq('the_table_name')
    end
  end

  describe '#deploys_for' do
    let(:apps) { { 'frontend' => 'abc' } }
    let(:server) { 'uat.fundingcircle.com' }

    let(:defaults) { { app_name: 'frontend', server: server, deployed_by: 'Bob', version: 'abc' } }

    it 'projects last deploy' do
      repository.apply(build(:deploy_event, defaults.merge(version: 'abc')))
      results = repository.deploys_for(apps: apps, server: server)
      expect(results).to eq([Deploy.new(defaults.merge(version: 'abc', correct: true))])

      repository.apply(build(:deploy_event, defaults.merge(version: 'def')))
      results = repository.deploys_for(apps: apps, server: server)
      expect(results).to eq([Deploy.new(defaults.merge(version: 'def', correct: false))])
    end

    it 'is case insensitive when a repo name and the event app name do not match in case' do
      repository.apply(build(:deploy_event, defaults.merge(app_name: 'Frontend')))

      results = repository.deploys_for(apps: apps, server: server)
      expect(results).to eq([Deploy.new(defaults.merge(app_name: 'frontend', correct: true))])
    end

    it 'ignores the deploys event when it is for another server' do
      repository.apply(build(:deploy_event, defaults.merge(server: 'other.fundingcircle.com')))

      expect(repository.deploys_for(apps: apps, server: server)).to eq([])
    end

    it 'ignores the deploy event when it is for an app that is not under review' do
      repository.apply(build(:deploy_event, defaults.merge(app_name: 'irrelevant_app')))

      expect(repository.deploys_for(apps: apps, server: server)).to eq([])
    end

    it 'reports an incorrect version deployed to the UAT when event is for a different app version' do
      repository.apply(build(:deploy_event, defaults))
      expect(repository.deploys_for(apps: apps, server: server).map(&:correct)).to eq([true])

      repository.apply(build(:deploy_event, defaults.merge(version: 'def')))
      expect(repository.deploys_for(apps: apps, server: server).map(&:correct)).to eq([false])
    end

    context 'with multiple apps' do
      let(:apps) { { 'frontend' => 'abc', 'backend' => 'abc' } }

      it 'returns multiple deploys' do
        repository.apply(build(:deploy_event, defaults.merge(app_name: 'frontend')))
        repository.apply(build(:deploy_event, defaults.merge(app_name: 'backend')))

        expect(repository.deploys_for(apps: apps, server: server)).to match_array([
          Deploy.new(defaults.merge(app_name: 'frontend', correct: true)),
          Deploy.new(defaults.merge(app_name: 'backend', correct: true)),
        ])
      end
    end

    context 'with no apps' do
      it 'returns deploys for all apps to that server' do
        repository.apply(build(:deploy_event, server: 'x.io', version: '1', app_name: 'a', deployed_by: 'dj'))
        repository.apply(build(:deploy_event, server: 'x.io', version: '2', app_name: 'b', deployed_by: 'dj'))
        repository.apply(build(:deploy_event, server: 'y.io', version: '3', app_name: 'c', deployed_by: 'dj'))

        results = repository.deploys_for(server: 'x.io')

        expect(results).to match_array([
          Deploy.new(app_name: 'a', server: 'x.io', version: '1', deployed_by: 'dj', correct: false),
          Deploy.new(app_name: 'b', server: 'x.io', version: '2', deployed_by: 'dj', correct: false),
        ])
      end
    end

    context 'with at specified' do
      let(:defaults) { { server: 'x.io', deployed_by: 'dj' } }

      it 'returns the state at that moment' do
        events = [
          build(:deploy_event, defaults.merge(version: 'abc', app_name: 'app1', created_at: 3.hours.ago)),
          build(:deploy_event, defaults.merge(server: 'y.io', app_name: 'app1', created_at: 2.hours.ago)),
          build(:deploy_event, defaults.merge(version: 'def', app_name: 'app2', created_at: 1.hours.ago)),
          build(:deploy_event, defaults.merge(version: 'ghi', app_name: 'app1', created_at: Time.current)),
        ]

        events.each do |event|
          repository.apply(event)
        end

        results = repository.deploys_for(
          apps: {
            'app1' => 'abc',
            'app2' => 'def',
          },
          server: 'x.io',
          at: 2.hours.ago,
        )

        expect(results).to match_array([
          Deploy.new(app_name: 'app1', server: 'x.io', version: 'abc', deployed_by: 'dj', correct: true),
        ])
      end
    end
  end
end
