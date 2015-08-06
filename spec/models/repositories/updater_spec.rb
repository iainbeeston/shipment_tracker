require 'rails_helper'
require 'repositories/updater'

RSpec.describe Repositories::Updater do
  describe '.from_rails_config' do
    let(:expected_updater) { double('updater') }

    before do
      allow(Repositories::Updater).to receive(:new)
        .with(Rails.configuration.repositories)
        .and_return(expected_updater)
    end

    it 'returns a configured updater' do
      expect(Repositories::Updater.from_rails_config).to eq(expected_updater)
    end
  end

  let(:repository_1) { instance_double(Repositories::BuildRepository, 'repository_1', table_name: 'tbl_1') }
  let(:repository_2) { instance_double(Repositories::DeployRepository, 'repository_2', table_name: 'tbl_2') }
  let(:repositories) { [repository_1, repository_2] }

  let(:events) { [build(:jira_event), build(:jira_event)] }

  subject(:updater) { Repositories::Updater.new(repositories) }

  describe '#run' do
    it 'feeds events to each repository' do
      events.each(&:save!)

      expect(repository_1).to receive(:apply).with(events[0]).ordered
      expect(repository_1).to receive(:apply).with(events[1]).ordered

      expect(repository_2).to receive(:apply).with(events[0]).ordered
      expect(repository_2).to receive(:apply).with(events[1]).ordered

      updater.run
    end

    context 'when the application is updated and we have different repositories specified' do
      let(:events) { [build(:jira_event), build(:jira_event)] }
      let(:new_events) { [build(:jira_event)] }

      it 'only feeds events that are new for each repository' do
        events.each(&:save!)

        expect(repository_1).to receive(:apply).with(events[0]).ordered
        expect(repository_1).to receive(:apply).with(events[1]).ordered

        Repositories::Updater.new([repository_1]).run

        new_events.each(&:save!)

        expect(repository_1).to receive(:apply).with(new_events[0]).ordered
        expect(repository_2).to receive(:apply).with(events[0]).ordered
        expect(repository_2).to receive(:apply).with(events[1]).ordered
        expect(repository_2).to receive(:apply).with(new_events[0]).ordered

        Repositories::Updater.new([repository_1, repository_2]).run
      end
    end
  end
end
