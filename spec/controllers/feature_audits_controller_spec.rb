require 'rails_helper'

describe FeatureAuditsController do
  describe "GET #show" do
    let(:feature_audit_projection) do
      instance_double(FeatureAuditProjection,
        authors: ['Alice', 'Bob', 'Mike'],
        deploys: ['deploy1', 'deploy2', 'deploy3']
      )
    end

    it "shows a feature audit" do
      allow(FeatureAuditProjection).to receive(:for).with(
        repository_name: 'app1',
        from: 'abc',
        to:   'xyz'
      ).and_return(feature_audit_projection)

      get :show, id: 'app1', from: 'abc', to: 'xyz'

      expect(assigns(:authors)).to eql(feature_audit_projection.authors)
      expect(assigns(:deploys)).to eql(feature_audit_projection.deploys)
    end
  end
end
