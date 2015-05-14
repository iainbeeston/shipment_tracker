require 'rails_helper'

describe FeatureAuditsController do
  describe 'GET #show' do
    let(:feature_audit_projection) do
      instance_double(
        FeatureAuditProjection,
        authors: %w(Alice Bob Mike),
        builds: %w(some builds),
        comments: %w(some comments),
        deploys: %w(deploy1 deploy2 deploy3),
        tickets: %w(some tickets),
        valid?: true,
        to: 'xyz',
      )
    end

    let(:git_repository_loader) do
      instance_double(GitRepositoryLoader, :load)
    end

    let(:git_repository) do
      instance_double(GitRepository)
    end

    let(:events) { [Event.new, Event.new, Event.new] }

    before do
      allow(GitRepositoryLoader).to receive(:new).and_return(git_repository_loader)

      allow(FeatureAuditProjection).to receive(:new).with(
        git_repository: git_repository,
        from: 'abc',
        to:   'xyz',
      ).and_return(feature_audit_projection)

      allow(Event).to receive(:in_order_of_creation).and_return(events)
    end

    it 'shows a feature audit' do
      expect(git_repository_loader).to receive(:load).with('app1').and_return(git_repository)
      expect(feature_audit_projection).to receive(:apply_all).with(events)

      get :show, id: 'app1', from: 'abc', to: 'xyz'

      expect(assigns(:to_version)).to eql('xyz')
      expect(assigns(:valid)).to be(true)

      expect(assigns(:authors)).to eql(feature_audit_projection.authors)
      expect(assigns(:builds)).to eql(feature_audit_projection.builds)
      expect(assigns(:comments)).to eql(feature_audit_projection.comments)
      expect(assigns(:deploys)).to eql(feature_audit_projection.deploys)
      expect(assigns(:tickets)).to eql(feature_audit_projection.tickets)
    end
  end
end
