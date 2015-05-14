require 'rails_helper'
require 'feature_audit_projection'

RSpec.describe FeatureAuditProjection do
  let(:git_repository) { instance_double(GitRepository) }

  subject(:projection) do
    FeatureAuditProjection.new(
      from: 'a_commit',
      to: 'another_commit',
      git_repository: git_repository,
    )
  end

  before do
    allow(git_repository).to receive(:commits_between)
      .with('a_commit', 'another_commit')
      .and_return(commits)
  end

  describe 'authors projection' do
    let(:commit_authors) { %w(Alice Bob Carol) }
    let(:commits) { commit_authors.map { |author| build(:git_commit, author_name: author) } }

    it 'builds the list of authors' do
      expect(projection.authors).to match_array(commit_authors)
    end
  end

  describe 'deploys projection' do
    let(:commits) { commit_versions.map { |version| build(:git_commit, id: version) } }
    let(:commit_versions) { %w(middle_commit another_commit) }

    it 'builds the list of deploys' do
      events = [
        build(:deploy_event, server: 'pub.example.com', deployed_by: 'Alfred', version: 'a_commit'),
        build(:deploy_event, server: 'pub.example.com', deployed_by: 'Alfred', version: 'another_commit'),
        build(:deploy_event, server: 'pub.example.com', deployed_by: 'Bob',    version: 'another_commit'),
      ]

      projection.apply_all(events)

      expect(projection.deploys).to match_array([
        Deploy.new(server: 'pub.example.com', version: 'another_commit', deployed_by: 'Alfred'),
        Deploy.new(server: 'pub.example.com', version: 'another_commit', deployed_by: 'Bob'),
      ])
    end
  end

  describe 'tickets projection' do
    let(:commits) { commit_messages.map { |message| build(:git_commit, message: message) } }
    let(:commit_messages) { ['JIRA-1 first', 'JIRA-2 second', 'JIRA-3 third'] }

    it 'builds the list of tickets' do
      events = [
        build(:jira_event, key: 'JIRA-1', summary: 'Start', status: 'To Do',       user_email: 'bob@foo.io'),
        build(:jira_event, key: 'JIRA-2', summary: 'More',  status: 'In Progress', user_email: 'fran@foo.io'),
      ]

      projection.apply_all(events)

      expect(projection.tickets).to match_array([
        Ticket.new(key: 'JIRA-1', summary: 'Start', status: 'To Do',       approver_email: nil),
        Ticket.new(key: 'JIRA-2', summary: 'More',  status: 'In Progress', approver_email: nil),
      ])
    end

    context 'when there are multiple commits for the same ticket' do
      let(:commit_messages) { ['JIRA-1 first', 'JIRA-1 second'] }

      it 'ignores the commit messages' do
        events = [
          build(:jira_event, key: 'JIRA-1', summary: 'Some work', status: 'To Do', user_email: 'bob@foo.io'),
        ]

        projection.apply_all(events)

        expect(projection.tickets).to match_array([
          Ticket.new(key: 'JIRA-1', summary: 'Some work', status: 'To Do', approver_email: nil),
        ])
      end
    end

    context 'when commits reference JIRA tickets that we have not received events for' do
      let(:commit_messages) { ['JIRA-1 first', 'JIRA-9 ignored'] }

      it 'ignores the commit messages' do
        events = [
          build(:jira_event, key: 'JIRA-1', summary: 'Some work', status: 'To Do', user_email: 'bob@foo.io'),
        ]

        projection.apply_all(events)

        expect(projection.tickets).to match_array([
          Ticket.new(key: 'JIRA-1', summary: 'Some work', status: 'To Do', approver_email: nil),
        ])
      end
    end

    context 'when events reference JIRA tickets that we have not seen commits for' do
      let(:jira_event_keys) { %w(JIRA-9 JIRA-1) }
      let(:commit_messages) { ['JIRA-1 first'] }

      it 'ignores the commit messages' do
        events = [
          build(:jira_event, key: 'JIRA-9', summary: 'No work', status: 'To Do', user_email: 'lucky@foo.io'),
          build(:jira_event, key: 'JIRA-1', summary: 'Some work', status: 'To Do', user_email: 'bob@foo.io'),
        ]

        projection.apply_all(events)

        expect(projection.tickets).to match_array([
          Ticket.new(key: 'JIRA-1', summary: 'Some work', status: 'To Do', approver_email: nil),
        ])
      end
    end

    context 'as the state of a ticket changes' do
      let(:commit_messages) { ['JIRA-1 first'] }

      it 'tracks the current status' do
        projection.apply(build(:jira_event, key: 'JIRA-1'))
        expect(projection.tickets.first.status).to eq('To Do')

        projection.apply(build(:jira_event, :in_progress, key: 'JIRA-1'))
        expect(projection.tickets.first.status).to eq('In Progress')

        projection.apply(build(:jira_event, :ready_for_review, key: 'JIRA-1'))
        expect(projection.tickets.first.status).to eq('Ready For Review')

        projection.apply(build(:jira_event, :done, key: 'JIRA-1'))
        expect(projection.tickets.first.status).to eq('Done')

        expect(projection.tickets.size).to eq(1)
      end

      it 'records the approver' do
        projection.apply(build(:jira_event, key: 'JIRA-1'))
        projection.apply(build(:jira_event, :done, key: 'JIRA-1',
                                                   user_email: 'approver@foo.io',
                                                   updated: '2015-06-07T15:24:34.957+0100'))
        projection.apply(build(:jira_event, :done, key: 'JIRA-1', changelog_details: {}))

        expect(projection.tickets.first.status).to eq('Done')
        expect(projection.tickets.first.approver_email).to eq('approver@foo.io')
        expect(projection.tickets.first.approved_at).to eq(Time.parse('2015-06-07T15:24:34.957+0100'))

        projection.apply(build(:jira_event, :done, key: 'JIRA-1',
                                                   user_email: 'user_who_changed_description@foo.io',
                                                   updated: '2015-07-08T16:14:38.123+0100',
                                                   changelog_details: {}))

        expect(projection.tickets.first.approver_email).to eq('approver@foo.io')
        expect(projection.tickets.first.approved_at).to eq(Time.parse('2015-06-07T15:24:34.957+0100'))
      end

      context 'when the ticket is unapproved' do
        it 'removes the approver information' do
          projection.apply(build(:jira_event, key: 'JIRA-1'))
          projection.apply(build(:jira_event, :done, key: 'JIRA-1'))
          projection.apply(build(:jira_event, :to_do, key: 'JIRA-1'))

          expect(projection.tickets.first.approver_email).to be nil
          expect(projection.tickets.first.approved_at).to be nil
        end
      end
    end
  end

  describe 'builds projection' do
    let(:commits) { commit_versions.map { |version| build(:git_commit, id: version) } }
    let(:commit_versions) { %w(middle_commit another_commit) }

    it 'builds the list of builds' do
      events = [
        build(:circle_ci_event, success?: true, version: 'a_commit'),
        build(:circle_ci_event, success?: true, version: 'another_commit'),
        build(:jenkins_event, success?: false, version: 'another_commit'),
        build(:jenkins_event, success?: false, version: 'a_commit'),
      ]

      projection.apply_all(events)

      expect(projection.builds).to match_array([
        Build.new(source: 'CircleCi', status: 'success', version: 'another_commit'),
        Build.new(source: 'Jenkins', status: 'failed', version: 'another_commit'),
      ])
    end
  end
end
