require 'rails_helper'

RSpec.describe 'EventsController' do
  describe 'POST #create' do
    let(:event_factory) { instance_double(EventFactory) }

    before do
      allow(EventFactory).to receive(:new).and_return(event_factory)
    end

    context 'with a cookie' do
      let(:user_email) { 'alice@fundingcircle.com' }

      before do
        login_with_auth0
      end

      it 'saves the event' do
        expect(event_factory).to receive(:create).with(
          'circleci',
          { 'foo' => 'bar' },
          an_object_having_attributes(email: user_email),
        )

        post '/events/circleci', foo: 'bar'

        expect(response).to be_ok
        expect(response.headers).to have_key('Set-Cookie')
      end
    end

    context 'with a valid token in the path' do
      let(:token) { 'abc123' }

      before do
        allow(Token).to receive(:valid?).and_return(false)
        allow(Token).to receive(:valid?).with('circleci', token).and_return(true)
      end

      it 'saves the event' do
        expect(event_factory).to receive(:create).with(
          'circleci',
          { 'foo' => 'bar', 'token' => 'the payloads token' },
          an_object_having_attributes(email: nil)
        )

        post "/events/circleci?token=#{token}", foo: 'bar', token: 'the payloads token'

        expect(response).to be_ok
      end

      it 'does not create authorised session' do
        expect(event_factory).to receive(:create).once

        post "/events/circleci?token=#{token}", foo: 'bar', token: 'the payloads token'

        # subsequent post without token should not work
        post '/events/circleci', more: 'data'
        expect(response).to be_forbidden
      end
    end

    context 'with no token' do
      it 'returns 403 Forbidden' do
        post '/events/circleci', foo: 'bar'

        expect(response).to be_forbidden
      end
    end

    context 'with an invalid token' do
      it 'returns 403 Forbidden' do
        post '/events/circleci?token=asdfasdf', foo: 'bar'

        expect(response).to be_forbidden
      end
    end
  end

  private

  def login_with_auth0
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:auth0] = {
      'uid' => 'xzy',
      'info' => {
        'email' => user_email,
        'first_name' => 'Alice',
      },
    }
    get Rails.configuration.login_callback_url
  ensure
    OmniAuth.config.test_mode = false
  end
end
