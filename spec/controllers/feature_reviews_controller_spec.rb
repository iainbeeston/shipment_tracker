require 'rails_helper'

RSpec.describe FeatureReviewsController do
  describe 'GET #index', skip_login: true do
    it 'requires login' do
      expect_any_instance_of(ApplicationController).to receive(:require_login).at_least(1).times
      get :index
    end

    context 'our routing' do
      it 'matches the feature_review_location'do
        actual_url = @routes.url_for host: 'www.example.com',
                                     controller: 'feature_reviews',
                                     action: 'index',
                                     apps: { a: '123', b: '456' },
                                     uat_url: 'http://foo.com'

        feature_review_location = FeatureReviewLocation.new(actual_url)
        expect(feature_review_location.app_versions).to eq(a: '123', b: '456')
        expect(feature_review_location.uat_url).to eq('http://foo.com')
      end
    end

    context 'when apps are submitted' do
      let(:projection) { instance_double(FeatureReviewProjection) }
      let(:presenter) { instance_double(FeatureReviewPresenter) }
      let(:events) { [Event.new, Event.new, Event.new] }
      let(:uat_url) { 'http://uat.fundingcircle.com' }
      let(:apps_with_versions) { { 'frontend' => 'abc', 'backend' => 'def' } }
      let(:apps_without_versions) { { 'irrelevant_app_without_version' => '' } }
      let(:all_apps) { apps_with_versions.merge(apps_without_versions) }

      let(:projection_url) {
        @routes.url_for host: 'www.example.com',
                        controller: 'feature_reviews',
                        action: 'index',
                        apps: all_apps,
                        uat_url: uat_url
      }

      before do
        request.host = 'www.example.com'

        allow(FeatureReviewProjection).to receive(:build).with(
          apps: apps_with_versions,
          uat_url: uat_url,
          projection_url: projection_url,
        ).and_return(projection)

        allow(Event).to receive(:in_order_of_creation).and_return(events)

        allow(FeatureReviewPresenter).to receive(:new).with(projection).and_return(presenter)
      end

      it 'shows a report for each application', skip_login: true do
        expect(projection).to receive(:apply_all).with(events)

        get :index, apps: all_apps, uat_url: uat_url

        expect(assigns(:presenter)).to eq(presenter)
      end
    end

    context 'when no apps are submitted' do
      it 'shows an error', skip_login: true do
        get :index, apps: { 'frontend' => '', 'backend' => '' }

        expect(response).to redirect_to(new_feature_review_path)
        expect(flash[:error]).to include('Please specify at least one app')
      end
    end
  end

  describe 'GET #search', skip_login: true do
    context 'when no search entered' do
      it 'it assigns links as empty' do
        get :search
        expect(assigns(:links)).to be_empty
      end
    end

    context 'when search query submitted' do
      let(:projection) { instance_double(FeatureReviewSearchProjection) }

      let(:expected_links) { ['/somelink'] }
      let(:locations) {
        [
          RepositoryLocation.new(name: 'frontend'),
          RepositoryLocation.new(name: 'backend'),
        ]
      }
      let(:frontend_repo) { instance_double(GitRepository) }
      let(:backend_repo) { instance_double(GitRepository) }
      let(:repos) { [frontend_repo, backend_repo] }

      before do
        allow(RepositoryLocation).to receive(:all).and_return([])
        allow(FeatureReviewSearchProjection).to receive(:new).and_return(projection)
        allow(projection).to receive(:feature_requests_for).with('abc123').and_return(expected_links)
      end

      it 'assigns links for found Feature Reviews' do
        get :search, version: 'abc123'
        expect(assigns(:links)).to eq(expected_links)
      end

      it 'searches accross all repository locations' do
        allow(RepositoryLocation).to receive(:all).and_return(locations)

        expect_any_instance_of(GitRepositoryLoader).to receive(:load)
          .with('frontend')
          .and_return(frontend_repo)

        expect_any_instance_of(GitRepositoryLoader).to receive(:load)
          .with('backend')
          .and_return(backend_repo)

        allow(FeatureReviewSearchProjection).to receive(:new)
          .with(git_repositories: repos)
          .and_return(projection)

        get :search, version: 'abc123'
      end
    end
  end
end
