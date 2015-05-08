require 'rails_helper'
require 'feature_audit_projection'

RSpec.describe FeatureAuditProjection do
  let(:git_repository) { class_double(GitRepository) }

  subject(:projection) do
    described_class.new(
      app_name: 'app_name',
      from: 'a_commit',
      to: 'another_commit',
      git_repository: git_repository
    )
  end

  describe "#apply_all" do
    before do
      allow(git_repository).to receive(:commits_for)
        .with(repository_name: 'app_name', from: 'a_commit', to: 'another_commit')
        .and_return(commits)
    end

    let(:commit_messages) { ['JIRA-123 first', 'JIRA-456 second', 'JIRA-789 third'] }
    let(:commits) { commit_messages.map { |message| build(:git_commit, message: message) } }

    it "builds the list of tickets" do
      events = [
        build(:jira_event, key: 'JIRA-123', summary: 'Some work', status: 'To Do',       user_email: 'bob@example.com'),
        build(:jira_event, key: 'JIRA-456', summary: 'More work', status: 'In Progress', user_email: 'frank@example.com')
      ]

      projection.apply_all(events)

      expect(projection.tickets).to match_array([
        Ticket.new(key: 'JIRA-123', summary: 'Some work', status: 'To Do',       approver_email: nil),
        Ticket.new(key: 'JIRA-456', summary: 'More work', status: 'In Progress', approver_email: nil)
      ])
    end

    context 'when there are multiple commits for the same ticket' do
      let(:commit_messages) { ['JIRA-123 first', 'JIRA-123 second'] }

      it "ignores the commit messages" do
        events = [
          build(:jira_event, key: 'JIRA-123', summary: 'Some work', status: 'To Do', user_email: 'bob@example.com'),
        ]

        projection.apply_all(events)

        expect(projection.tickets).to match_array([
          Ticket.new(key: 'JIRA-123', summary: 'Some work', status: 'To Do', approver_email: nil),
        ])
      end
    end

    context 'when commits reference JIRA tickets that we have not received events for' do
      let(:commit_messages) { ['JIRA-123 first', 'JIRA-000 ignored'] }

      it "ignores the commit messages" do
        events = [
          build(:jira_event, key: 'JIRA-123', summary: 'Some work', status: 'To Do', user_email: 'bob@example.com'),
        ]

        projection.apply_all(events)

        expect(projection.tickets).to match_array([
          Ticket.new(key: 'JIRA-123', summary: 'Some work', status: 'To Do', approver_email: nil),
        ])
      end
    end

    context 'when events reference JIRA tickets that we have not seen commits for' do
      let(:jira_event_keys) { %w(JIRA-000 JIRA-123) }
      let(:commit_messages) { ['JIRA-123 first'] }

      it "ignores the commit messages" do
        events = [
          build(:jira_event, key: 'JIRA-000', summary: 'No work', status: 'To Do', user_email: 'lucky@example.com'),
          build(:jira_event, key: 'JIRA-123', summary: 'Some work', status: 'To Do', user_email: 'bob@example.com'),
        ]

        projection.apply_all(events)

        expect(projection.tickets).to match_array([
          Ticket.new(key: 'JIRA-123', summary: 'Some work', status: 'To Do', approver_email: nil),
        ])
      end
    end

    context 'as the state of a ticket changes' do
      let(:commit_messages) { ['JIRA-123 first'] }

      it 'tracks the current status' do
        projection.apply(build(:jira_event, :to_do, key: 'JIRA-123'))
        expect(projection.tickets.first.status).to eq('To Do')

        projection.apply(build(:jira_event, :in_progress, key: 'JIRA-123'))
        expect(projection.tickets.first.status).to eq('In Progress')

        projection.apply(build(:jira_event, :ready_for_review, key: 'JIRA-123'))
        expect(projection.tickets.first.status).to eq('Ready For Review')

        projection.apply(build(:jira_event, :done, key: 'JIRA-123'))
        expect(projection.tickets.first.status).to eq('Done')

        expect(projection.tickets.size).to eql(1)
      end

      it 'records the approver' do
        projection.apply(build(:jira_event, :to_do, key: 'JIRA-123'))
        projection.apply(build(:jira_event, :done, key: 'JIRA-123', user_email: 'approver@example.com'))
        expect(projection.tickets.first.status).to eq('Done')

        expect(projection.tickets.first.approver_email).to eq('approver@example.com')

        projection.apply(build(
          :jira_event,
          :done,
          key: 'JIRA-123',
          user_email: 'user_who_changed_description@example.com',
          change_log_items: [{'field'=>'description', 'toString'=>'New description'}]
        ))

        expect(projection.tickets.first.approver_email).to eq('approver@example.com')
      end
    end
  end
end
