require 'rails_helper'

describe FeatureAuditsController do
  describe "GET #show" do
    let(:feature_audit_projection) do
      instance_double(
        FeatureAuditProjection,
        authors: %w(Alice Bob Mike),
        deploys: %w(deploy1 deploy2 deploy3),
        tickets: %w(some tickets),
        builds: %w(some builds)
      )
    end

    let(:events) { [Event.new, Event.new, Event.new] }

    before do
      allow(FeatureAuditProjection).to receive(:new).with(
        app_name: 'app1',
        from: 'abc',
        to:   'xyz'
      ).and_return(feature_audit_projection)

      allow(Event).to receive(:all).and_return(events)
    end

    it "shows a feature audit" do
      expect(feature_audit_projection).to receive(:apply_all).with(events)

      get :show, id: 'app1', from: 'abc', to: 'xyz'

      expect(assigns(:authors)).to eql(feature_audit_projection.authors)
      expect(assigns(:deploys)).to eql(feature_audit_projection.deploys)
      expect(assigns(:tickets)).to eql(feature_audit_projection.tickets)
      expect(assigns(:builds)).to eql(feature_audit_projection.builds)
    end
  end
end
