require 'rails_helper'

RSpec.describe 'EventsController' do
  describe 'POST to :create' do
    context 'with a cookie' do
      before do
        login_with_auth0
      end

      it 'saves the event' do
        post '/events/circleci', foo: 'baz'

        expect(response).to be_ok
        expect(response.headers).to have_key('Set-Cookie')
        expect(Event.last).to be_a(CircleCiEvent)
        expect(Event.last.details).to eq('foo' => 'baz')
      end
    end

    context 'with a valid token in the path' do
      let(:token) { Token.create(source: 'circleci').value }

      it 'saves the event' do
        post "/events/circleci?token=#{token}", foo: 'bar', token: 'the payloads token'

        expect(response).to be_ok
        expect(Event.last).to be_a(CircleCiEvent)
        expect(Event.last.details).to eq('foo' => 'bar', 'token' => 'the payloads token')
      end

      it 'does not create authorised session' do
        post "/events/circleci?token=#{token}", foo: 'bar', token: 'the payloads token'

        # subsequent post without token should not work
        post '/events/circleci', more: 'data'
        expect(response).to be_forbidden
        expect(Event.count).to eq(1)
      end
    end

    context 'with no token' do
      it 'returns 403 Forbidden' do
        post '/events/circleci', foo: 'bar'

        expect(response).to be_forbidden
        expect(Event.count).to eq(0)
      end
    end

    context 'with an invalid token' do
      it 'returns 403 Forbidden' do
        post '/events/circleci?token=asdfasdf', foo: 'bar'

        expect(response).to be_forbidden
        expect(Event.count).to eq(0)
      end
    end
  end

  private

  def login_with_auth0(uid: '123', email: 'jon@example.com', first_name: 'Jon')
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth['auth0'] = { uid: uid, info: { email: email, first_name: first_name } }
    get Rails.configuration.login_callback_url
  ensure
    OmniAuth.config.test_mode = false
  end
end
