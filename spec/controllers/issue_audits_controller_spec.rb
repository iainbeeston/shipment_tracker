require 'rails_helper'

RSpec.describe IssueAuditsController do
  describe 'GET #index' do
    it 'returns http success' do
      get :index

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    let(:issue_audit_projection) do
      instance_double(
        IssueAuditProjection,
        ticket: 'JIRA-123',
      )
    end
    let(:git_repository_loader) { instance_double(GitRepositoryLoader) }
    let(:git_repository) { instance_double(GitRepository) }
    let(:events) { [Event.new, Event.new, Event.new] }

    before do
      allow(GitRepositoryLoader).to receive(:new).and_return(git_repository_loader)

      allow(IssueAuditProjection).to receive(:new).with(
        app_name: 'hello_world_rails',
        issue_name: 'JIRA-123',
        git_repository: git_repository,
      ).and_return(issue_audit_projection)

      allow(Event).to receive(:in_order_of_creation).and_return(events)
    end

    it 'shows an issue audit' do
      expect(git_repository_loader).to receive(:load).with('hello_world_rails').and_return(git_repository)
      expect(issue_audit_projection).to receive(:apply_all).with(events)

      get :show, id: 'JIRA-123'

      expect(assigns(:ticket)).to eq(issue_audit_projection.ticket)
    end
  end
end
