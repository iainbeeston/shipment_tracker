require 'rails_helper'

describe DeploysController do
  describe "POST #create" do
    it "creates a deploy event" do
      expect(Deploy).to receive(:create).with(details: {
        "deployed_by" => "alice",
        "controller" => "deploys",
        "action" => "create",
      })
      post :create, { deployed_by: "alice" }, format: :json
      expect(response).to have_http_status(:ok)
    end
  end
end
