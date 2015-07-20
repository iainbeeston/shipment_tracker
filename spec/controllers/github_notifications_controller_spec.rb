require 'rails_helper'

RSpec.describe GithubNotificationsController do
  describe 'POST #create' do
    let(:payload) { { 'github' => 'stuff' } }

    it 'updates the corresponsing RepositoryLocation' do
      expect(RepositoryLocation).to receive(:update_from_github_notification).with(payload)

      post :create, payload

      expect(response).to be_ok
    end
  end
end
