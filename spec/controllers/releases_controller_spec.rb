require 'rails_helper'

RSpec.describe ReleasesController, type: :controller do
  describe 'GET #index' do
    let(:app_names) { %w(frontend backend) }

    before do
      allow(RepositoryLocation).to receive(:app_names).and_return(app_names)
    end

    it 'displays the list of apps' do
      get :index

      expect(response).to have_http_status(:success)
      expect(assigns(:app_names)).to eq(app_names)
    end
  end

  describe 'GET #show' do
    let(:repository) { instance_double(GitRepository) }
    let(:repository_loader) { instance_double(GitRepositoryLoader) }
    let(:commits) { double('commits') }

    before do
      allow(GitRepositoryLoader).to receive(:from_rails_config).and_return(repository_loader)
      allow(repository_loader).to receive(:load).with('frontend').and_return(repository)
      allow(repository).to receive(:recent_commits).with(50).and_return(commits)
    end

    it 'shows the list of commits for an app' do
      get :show, id: 'frontend'

      expect(response).to have_http_status(:success)
      expect(assigns(:app_name)).to eq('frontend')
      expect(assigns(:commits)).to eq(commits)
    end
  end
end
