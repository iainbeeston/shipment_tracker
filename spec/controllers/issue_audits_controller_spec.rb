require 'rails_helper'

RSpec.describe IssueAuditsController do
  describe 'GET #index' do
    it 'returns http success' do
      get :index

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    let(:frontend_git_repository) { instance_double(GitRepository) }
    let(:backend_git_repository) { instance_double(GitRepository) }
    let(:valid_issue_audit_projection) { instance_double(IssueAuditProjection, valid?: true) }
    let(:invalid_issue_audit_projection) { instance_double(IssueAuditProjection, valid?: false) }
    let(:events) { double('events') }
    before do
      RepositoryLocation.create(name: 'frontend', uri: 'ssh://some.uri')
      RepositoryLocation.create(name: 'backend', uri: 'ssh://another.uri')
      allow(Event).to receive(:in_order_of_creation).and_return(events)

      allow_any_instance_of(GitRepositoryLoader).to receive(:load)
        .with('frontend')
        .and_return(frontend_git_repository)
      allow_any_instance_of(GitRepositoryLoader).to receive(:load)
        .with('backend')
        .and_return(backend_git_repository)
    end

    it 'returns all valid projectsion' do
      expect(IssueAuditProjection).to receive(:new).with(
        app_name: 'frontend',
        issue_name: 'JIRA-123',
        git_repository: frontend_git_repository,
      ).and_return(valid_issue_audit_projection)
      expect(IssueAuditProjection).to receive(:new).with(
        app_name: 'backend',
        issue_name: 'JIRA-123',
        git_repository: backend_git_repository,
      ).and_return(invalid_issue_audit_projection)

      expect(valid_issue_audit_projection).to receive(:apply_all).with(events)
      expect(invalid_issue_audit_projection).to receive(:apply_all).with(events)

      get :show, id: 'JIRA-123'

      expect(response).to have_http_status(:success)
      expect(assigns(:reports)).to match_array([valid_issue_audit_projection])
    end
  end
end
