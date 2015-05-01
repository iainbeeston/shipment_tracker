require 'rails_helper'

describe FeatureAuditsController do
  describe "GET #show" do
    let(:feature_audit_projection) do
      instance_double(
        FeatureAuditProjection,
        authors: %w(Alice Bob Mike),
        deploys: %w(deploy1 deploy2 deploy3)
      )
    end

    it "shows a feature audit" do
      allow(FeatureAuditProjection).to receive(:new).with(
        app_name: 'app1',
        from: 'abc',
        to:   'xyz'
      ).and_return(feature_audit_projection)

      get :show, id: 'app1', from: 'abc', to: 'xyz'

      expect(assigns(:authors)).to eql(feature_audit_projection.authors)
      expect(assigns(:deploys)).to eql(feature_audit_projection.deploys)
    end
  end
end
