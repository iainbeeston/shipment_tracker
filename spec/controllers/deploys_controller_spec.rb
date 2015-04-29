require 'rails_helper'

describe DeploysController do
  describe "GET #index" do
    let(:deploy_events) { [Event.new] * 3 }
    before { allow(Event).to receive(:deploys).and_return(deploy_events) }

    it "shows the list of deploy events" do
      get :index
      expect(assigns(:deploy_events)).to eq(deploy_events)
    end
  end

  describe "POST #create" do
    it "creates a deploy event" do
      expect(Event).to receive(:create_deploy).with(message: { deployed_by: "alice" })
      post :create, { deploy: { deployed_by: "alice" } }, format: :json
      expect(response).to have_http_status(:ok)
    end
  end
end
