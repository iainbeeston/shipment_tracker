require 'rails_helper'

RSpec.describe 'Authentication' do
  describe 'auth0' do
    context 'when not logged in' do
      let(:callback_url) { 'http://www.example.com/auth/auth0/callback' }

      it 'redirects to auth0' do
        get '/feature_reviews/new'

        expect(response).to redirect_to('/auth/auth0')

        follow_redirect!

        oauth_url = response['Location']
        oauth_url_query = Addressable::URI.parse(oauth_url).query_values

        expect(oauth_url_query['connection']).to eq('Username-Password-Authentication')
        expect(oauth_url_query['response_type']).to eq('code')
        expect(oauth_url_query['redirect_uri']).to eq(callback_url)
      end

      it 'redirects to failure if callback url does not have token' do
        get callback_url

        expect(response).to redirect_to('/auth/failure?message=invalid_credentials&strategy=auth0')
      end
    end
  end
end
