require 'rails_helper'

RSpec.describe FeatureReviewsController do
  describe 'GET #index' do
    let(:frontend_report) { instance_double(FeatureReviewProjection) }
    let(:backend_report) { instance_double(FeatureReviewProjection) }
    let(:events) { [Event.new, Event.new, Event.new] }

    before do
      allow(FeatureReviewProjection).to receive(:new)
        .with(app_name: 'frontend', version: 'abc')
        .and_return(frontend_report)
      allow(FeatureReviewProjection).to receive(:new)
        .with(app_name: 'backend', version: 'def')
        .and_return(backend_report)
      allow(Event).to receive(:in_order_of_creation).and_return(events)
    end

    it 'shows a report for each application' do
      expect(frontend_report).to receive(:apply_all).with(events)
      expect(backend_report).to receive(:apply_all).with(events)

      get :index, apps: { 'frontend' => 'abc', 'backend' => 'def', 'irrelevant' => '' }

      expect(assigns(:reports)).to match_array([frontend_report, backend_report])
    end
  end
end
