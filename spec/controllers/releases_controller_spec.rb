require 'rails_helper'

RSpec.describe ReleasesController do
  describe 'GET #index', skip_login: true do
    let(:app_names) { %w(frontend backend) }

    before do
      allow(RepositoryLocation).to receive(:app_names).and_return(app_names)
    end

    it 'displays the list of apps' do
      get :index

      expect(response).to have_http_status(:success)
      expect(assigns(:app_names)).to eq(app_names)
    end

    it 'requires login' do
      expect_any_instance_of(ApplicationController).to receive(:require_authentication).at_least(1).times
      get :index
    end
  end

  describe 'GET #show', skip_login: true do
    let(:repository) { instance_double(GitRepository) }
    let(:repository_loader) { instance_double(GitRepositoryLoader) }
    let(:releases) { double(:releases) }
    let(:projection) { instance_double(ReleasesProjection, releases: releases) }
    let(:events) { double(:events) }

    before do
      allow(GitRepositoryLoader).to receive(:from_rails_config).and_return(repository_loader)
      allow(repository_loader).to receive(:load).with('frontend').and_return(repository)
      allow(ReleasesProjection).to receive(:new).with(
        per_page: 50,
        git_repository: repository,
      ).and_return(projection)
      allow(Event).to receive(:in_order_of_creation).and_return(events)
    end

    it 'shows the list of commits for an app' do
      expect(projection).to receive(:apply_all).with(events)

      get :show, id: 'frontend'

      expect(response).to have_http_status(:success)
      expect(assigns(:app_name)).to eq('frontend')
      expect(assigns(:releases)).to eq(releases)
    end

    it 'requires login' do
      allow(projection).to receive(:apply_all)
      expect_any_instance_of(ApplicationController).to receive(:require_authentication).at_least(1).times
      get :show, id: 'frontend'
    end
  end
end
