require 'rails_helper'

describe EventsController do
  describe 'POST #create' do
    let(:token) { 'abc123' }
    let(:details) { { 'any' => 'value' } }

    context 'routing' do
      it 'routes /event/:type correctly' do
        expect(post: '/events/anything').to route_to(controller: 'events', action: 'create', type: 'anything')
      end
    end

    context 'when logged in' do
      before do
        logged_in(uid: 'circleci')
      end

      {
        'deploy'      => DeployEvent,
        'circleci'    => CircleCiEvent,
        'jenkins'     => JenkinsEvent,
        'jira'        => JiraEvent,
        'manual_test' => ManualTestEvent,
        'uat'         => UatEvent,
      }.each do |event_type, event_class|
        describe "POST /events/#{event_type}" do
          it "creates a #{event_class} event" do
            expect(event_class).to receive(:create).with(details: details)

            post :create, details.merge('type' => event_type), format: :json

            expect(response).to have_http_status(:success)
          end
        end
      end

      context 'with an unrecognized event type' do
        it 'throws an error' do
          expect {
            post :create, 'type' => 'other', 'any' => 'message', format: :json
          }.to raise_error(RuntimeError, "Unrecognized event type 'other'")
        end
      end

      context 'with a return_to param' do
        {
          '/my/projection?with=data' => '/my/projection?with=data',
          'http://evil.com/magic/url?with=query' => '/magic/url?with=query',
          '/path' => '/path',
        }.each do |url, path|
          it "redirects #{url} to the #{path}" do
            post :create, 'type' => 'circleci', 'return_to' => url

            expect(response).to redirect_to(path)
          end
        end

        it 'does not redirect when invalid' do
          post :create, 'return_to' => 'TOTALLY NOT VALID', 'type' => 'circleci'

          expect(response).to have_http_status(:success), 'Expected HTTP success as we should not redirect'
        end

        it 'does not redirect when blank' do
          post :create, 'return_to' => '', 'type' => 'circleci'

          expect(response).to have_http_status(:success), 'Expected HTTP success as we should not redirect'
        end
      end
    end

    context 'when logged out' do
      before do
        logged_out
      end

      it 'returns 403 Forbidden' do
        post :create, type: 'circleci'

        expect(response).to be_forbidden
      end
    end
  end
end
