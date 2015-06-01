require 'rails_helper'
require 'feature_audit_projection'
require 'support/shared_examples/tickets_projection_examples'

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

    it_behaves_like 'a tickets projection'
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
