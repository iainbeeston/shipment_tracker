require 'rails_helper'
require 'issue_audit_projection'

RSpec.describe IssueAuditProjection do
  let(:git_repository) { instance_double(GitRepository) }
  let(:commits) { [] }

  subject(:projection) do
    IssueAuditProjection.new(
      app_name: 'hello_world_rails',
      issue_name: 'JIRA-1',
      git_repository: git_repository,
    )
  end

  before do
    allow(git_repository).to receive(:unmerged_commits_matching_query)
      .with('JIRA-1')
      .and_return(commits)
  end

  describe 'authors projection' do
    let(:commit_authors) { %w(Alice Bob Carol) }
    let(:commits) { commit_authors.map { |author| build(:git_commit, author_name: author) } }

    it 'builds the list of authors' do
      expect(projection.authors).to match_array(commit_authors)
    end
  end

  describe 'ticket projection' do
    it 'builds the ticket status' do
      events = [
        build(:jira_event, key: 'JIRA-1', summary: 'Start', status: 'To Do', user_email: 'bob@foo.io'),
        build(:jira_event, key: 'JIRA-2', summary: 'Start too', status: 'To Do', user_email: 'alice@foo.io'),
      ]

      projection.apply_all(events)

      expect(projection.ticket)
        .to eq(Ticket.new(key: 'JIRA-1', summary: 'Start', status: 'To Do', approver_email: nil))
    end

    context 'when no event matches the ticket key' do
      it 'does not return a ticket' do
        expect(projection.ticket).to eq(nil)
      end
    end

    context 'as the state of a ticket changes' do
      let(:commit_messages) { ['JIRA-1 first'] }

      it 'tracks the current status' do
        projection.apply(build(:jira_event, key: 'JIRA-1'))
        expect(projection.ticket.status).to eq('To Do')

        projection.apply(build(:jira_event, :in_progress, key: 'JIRA-1'))
        expect(projection.ticket.status).to eq('In Progress')

        projection.apply(build(:jira_event, :ready_for_review, key: 'JIRA-1'))
        expect(projection.ticket.status).to eq('Ready For Review')

        projection.apply(build(:jira_event, :done, key: 'JIRA-1'))
        expect(projection.ticket.status).to eq('Done')
      end

      it 'records the approver' do
        projection.apply(build(:jira_event, key: 'JIRA-1'))
        projection.apply(build(:jira_event, :done, key: 'JIRA-1',
                                                   user_email: 'approver@foo.io',
                                                   updated: '2015-06-07T15:24:34.957+0100'))
        projection.apply(build(:jira_event, :done, key: 'JIRA-1', changelog_details: {}))

        expect(projection.ticket.status).to eq('Done')
        expect(projection.ticket.approver_email).to eq('approver@foo.io')
        expect(projection.ticket.approved_at).to eq(Time.parse('2015-06-07T15:24:34.957+0100'))

        projection.apply(build(:jira_event, :done, key: 'JIRA-1',
                                                   user_email: 'user_who_changed_description@foo.io',
                                                   updated: '2015-07-08T16:14:38.123+0100',
                                                   changelog_details: {}))

        expect(projection.ticket.approver_email).to eq('approver@foo.io')
        expect(projection.ticket.approved_at).to eq(Time.parse('2015-06-07T15:24:34.957+0100'))
      end

      context 'when the ticket is unapproved' do
        it 'removes the approver information' do
          projection.apply(build(:jira_event, key: 'JIRA-1'))
          projection.apply(build(:jira_event, :done, key: 'JIRA-1'))
          projection.apply(build(:jira_event, :to_do, key: 'JIRA-1'))

          expect(projection.ticket.approver_email).to be nil
          expect(projection.ticket.approved_at).to be nil
        end
      end
    end
  end

  describe 'builds projection' do
    let(:commit) { GitCommit.new(id: 'a_commit') }

    before do
      allow(git_repository).to receive(:last_unmerged_commit_matching_query).with('JIRA-1').and_return(commit)
    end

    it 'builds the list of builds' do
      events = [
        build(:circle_ci_event, success?: false, version: 'a_commit'),
        build(:jenkins_event, success?: false, version: 'another_commit'),
        build(:circle_ci_event, success?: true, version: 'a_commit'),
      ]

      projection.apply_all(events)

      expect(projection.builds).to match_array([
        Build.new(source: 'CircleCi', status: 'failed', version: 'a_commit'),
        Build.new(source: 'CircleCi', status: 'success', version: 'a_commit'),
      ])
    end
  end
end
