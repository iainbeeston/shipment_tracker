require 'rails_helper'

RSpec.describe GithubNotificationsController do
  describe 'POST #create', :logged_in do
    context 'when event is a pull request' do
      before do
        request.env['HTTP_X_GITHUB_EVENT'] = 'pull_request'
      end

      context 'when the pull request is newly opened' do
        let(:sha) { '12345' }
        let(:owner) { 'FundingCircle' }
        let(:repo_name) { 'hello_world_rails' }
        let(:payload) {
          {
            'action' => 'opened',
            'pull_request' => {
              'head' => {
                'sha' => sha,
              },
              'base' => {
                'repo' => {
                  'owner' => {
                    'login' => owner,
                  },
                  'name' => repo_name,
                },
              },
            },
          }
        }

        it 'sets the pull request status' do
          pull_request_status = instance_double(PullRequestStatus)
          expect(PullRequestStatus).to receive(:new).with(
            repo_name: repo_name,
            owner: owner,
            sha: sha,
          ).and_return(pull_request_status)
          expect(pull_request_status).to receive(:update)

          post :create, github_notification: payload
        end
      end

      context 'when the pull request receives a new commit' do
        let(:sha) { '12345' }
        let(:owner) { 'FundingCircle' }
        let(:repo_name) { 'hello_world_rails' }
        let(:payload) {
          {
            'action' => 'synchronize',
            'pull_request' => {
              'head' => {
                'sha' => sha,
              },
              'base' => {
                'repo' => {
                  'owner' => {
                    'login' => owner,
                  },
                  'name' => repo_name,
                },
              },
            },
          }
        }

        it 'sets the pull request status' do
          pull_request_status = instance_double(PullRequestStatus)
          expect(PullRequestStatus).to receive(:new).with(
            repo_name: repo_name,
            owner: owner,
            sha: sha,
          ).and_return(pull_request_status)
          expect(pull_request_status).to receive(:update)

          post :create, github_notification: payload
        end
      end

      context 'when the pull request activity is not relevant' do
        let(:sha) { '12345' }
        let(:owner) { 'FundingCircle' }
        let(:repo_name) { 'hello_world_rails' }
        let(:payload) {
          {
            'action' => 'reopened',
            'pull_request' => {
              'head' => {
                'sha' => sha,
              },
              'base' => {
                'repo' => {
                  'owner' => {
                    'login' => owner,
                  },
                  'name' => repo_name,
                },
              },
            },
          }
        }

        it 'does not set the pull request status' do
          expect(PullRequestStatus).to_not receive(:new)

          post :create, github_notification: payload
        end
      end
    end

    context 'when event is a push' do
      before do
        request.env['HTTP_X_GITHUB_EVENT'] = 'push'
      end

      let(:payload) { {} }

      it 'updates the corresponding repository location' do
        expect(GitRepositoryLocation).to receive(:update_from_github_notification).with(payload)

        post :create, payload
      end
    end

    context 'when event is not recognized' do
      it 'responds with a 400 Bad Request' do
        post :create

        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
