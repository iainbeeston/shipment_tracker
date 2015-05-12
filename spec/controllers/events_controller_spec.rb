require 'rails_helper'

describe EventsController do
  describe "POST #create" do
    context "with return_to param" do
      {
        '/my/projection?with=data' => '/my/projection?with=data',
        'http://evil.com/magic/url?with=query' => '/magic/url?with=query',
        '/path' => '/path'
      }.each do |url, path|
        it "redirects #{url} to the #{path}" do
          post :create,
            'type' => 'comments',
            'return_to' => url

          expect(response).to redirect_to(path)
        end
      end

      it 'does not redirect when invalid' do
        post :create, 'return_to' => 'TOTALLY NOT VALID', 'type' => 'comments'

        expect(response).to have_http_status(:success), 'Expected HTTP success as we should not redirect'
      end

      it 'does not redirect when blank' do
        post :create, 'return_to' => '', 'type' => 'comments'

        expect(response).to have_http_status(:success), 'Expected HTTP success as we should not redirect'
      end
    end

    context "/comments with valid JSON" do
      let(:route_params) { { type: 'comments' } }

      it { should route(:post, '/events/deploy').to(action: :create, type: 'deploy') }

      it "saves an event object with correct details" do
        post :create, route_params.merge('name' => 'alice', 'message' => 'hello')

        expect(CommentEvent.last.details).to eql('name' => 'alice', 'message' => 'hello')
        expect(response).to have_http_status(:success)
      end
    end

    context "/deploy with valid JSON" do
      let(:route_params) { { type: 'deploy' } }

      it { should route(:post, '/events/deploy').to(action: :create, type: 'deploy') }

      it "saves an event object with correct details" do
        post :create, route_params.merge('deployed_by' => 'alice'), format: :json

        expect(DeployEvent.last.details).to eql('deployed_by' => 'alice')
        expect(response).to have_http_status(:success)
      end
    end

    context "/circle with valid JSON" do
      let(:route_params) { { type: 'circleci' } }

      it { should route(:post, '/events/circleci').to(action: :create, type: 'circleci') }

      it "saves an event object with correct details" do
        post :create, route_params.merge('status' => 'success'), format: :json

        expect(CircleCiEvent.last.details).to eql('status' => 'success')
        expect(response).to have_http_status(:success)
      end
    end

    context "/jenkins with valid JSON" do
      let(:route_params) { { type: 'jenkins' } }

      it { should route(:post, '/events/jenkins').to(action: :create, type: 'jenkins') }

      it "saves an event object with correct details" do
        post :create, route_params.merge('jenkins' => 'hudson'), format: :json

        expect(JenkinsEvent.last.details).to eql('jenkins' => 'hudson')
        expect(response).to have_http_status(:success)
      end
    end

    context "/jira with valid JSON" do
      let(:route_params) { { type: 'jira' } }

      it { should route(:post, '/events/jira').to(action: :create, type: 'jira') }

      it "saves an event object with correct details" do
        post :create, route_params.merge('issue' => { 'key' => 'JIRA-123' }), format: :json

        expect(JiraEvent.last.details).to eql('issue' => { 'key' => 'JIRA-123' })
        expect(response).to have_http_status(:success)
      end
    end

    context "/other with valid JSON" do
      let(:route_params) { { type: 'other' } }

      it { should route(:post, '/events/other').to(action: :create, type: 'other') }

      it "throws an error" do
        expect {
          post :create, route_params.merge('any' => 'message'), format: :json
        }.to raise_error
      end
    end
  end
end
