require 'rails_helper'

RSpec.describe RepositoryLocationsController do

  describe 'GET #index' do
    context 'when logged out' do
      it 'responds with redirect to auth0 provider' do
        get :index
        expect(response).to redirect_to('/auth/auth0')
      end
    end
  end

  describe 'POST #create' do
    context 'when logged out' do
      it 'redirects to auth0 provider' do
        post :create, repository_location: {
          'name' => 'shipment_tracker',
          'uri' => 'https://github.com/FundingCircle/shipment_tracker.git',
        }

        expect(response).to redirect_to('/auth/auth0')
      end
    end
  end
end
