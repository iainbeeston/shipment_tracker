require 'rails_helper'

RSpec.describe FeatureReviewsController do
  describe 'GET #index' do
    let(:projection) { instance_double(FeatureReviewProjection) }
    let(:events) { [Event.new, Event.new, Event.new] }
    let(:apps) { { 'frontend' => 'abc', 'backend' => 'def' } }

    before do
      allow(FeatureReviewProjection).to receive(:new).with(apps).and_return(projection)
      allow(Event).to receive(:in_order_of_creation).and_return(events)
    end

    it 'shows a report for each application' do
      expect(projection).to receive(:apply_all).with(events)

      get :index, apps: apps.merge('irrelevant_app_with_empty_version' => '')

      expect(assigns(:projection)).to eq(projection)
    end
  end
end
