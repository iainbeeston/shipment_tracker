require 'rails_helper'

RSpec.describe 'GithubNotificationsController' do
  describe 'POST #create' do
    let(:payload) { { 'github' => 'stuff', 'token' => 'the payloads token'  } }

    context 'with a cookie' do
      let(:user_email) { 'alice@fundingcircle.com' }

      before do
        login_with_omniauth(email: user_email)
      end

      it 'updates the corresponsing RepositoryLocation' do
        expect(RepositoryLocation).to receive(:update_from_github_notification).with(payload)

        post '/github_notifications', payload

        expect(response).to be_ok
      end
    end

    context 'with a valid token in the path' do
      let(:token) { 'abc123' }

      before do
        allow(Token).to receive(:valid?).and_return(false)
        allow(Token).to receive(:valid?).with('github_notifications', token).and_return(true)
      end

      it 'updates the corresponsing RepositoryLocation' do
        expect(RepositoryLocation).to receive(:update_from_github_notification).with(payload)

        post "/github_notifications?token=#{token}", payload

        expect(response).to be_ok
      end

      it 'does not create authorised session' do
        expect(RepositoryLocation).to receive(:update_from_github_notification).with(payload)

        post "/github_notifications?token=#{token}", payload

        # subsequent post without token should not work
        post '/github_notifications', payload
        expect(response).to be_forbidden
      end
    end

    context 'with no token' do
      it 'returns 403 Forbidden' do
        post '/github_notifications', foo: 'bar'

        expect(response).to be_forbidden
      end
    end

    context 'with an invalid token' do
      it 'returns 403 Forbidden' do
        post '/github_notifications?token=asdfasdf', foo: 'bar'

        expect(response).to be_forbidden
      end
    end
  end
end
