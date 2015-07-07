require 'rails_helper'

RSpec.describe FeatureReviewsController do
  context 'our routing' do
    it 'matches the feature_review_location'do
      actual_url = @routes.url_for host: 'www.example.com',
                                   controller: 'feature_reviews',
                                   action: 'show',
                                   apps: { a: '123', b: '456' },
                                   uat_url: 'http://foo.com'

      feature_review_location = FeatureReviewLocation.new(actual_url)
      expect(feature_review_location.app_versions).to eq(a: '123', b: '456')
      expect(feature_review_location.uat_url).to eq('http://foo.com')
    end
  end

  context 'when logged out' do
    it { is_expected.to require_authentication_on(:get, :new) }
    it { is_expected.to require_authentication_on(:get, :show) }
    it { is_expected.to require_authentication_on(:get, :search) }
  end

  describe 'GET #show' do
    context 'when apps are submitted', :logged_in do
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
                        action: 'show',
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

      it 'shows a report for each application' do
        expect(projection).to receive(:apply_all).with(events)

        get :show, apps: all_apps, uat_url: uat_url

        expect(assigns(:presenter)).to eq(presenter)
      end
    end

    context 'when no apps are submitted', :logged_in do
      it 'shows an error' do
        get :show, apps: { 'frontend' => '', 'backend' => '' }

        expect(response).to redirect_to(new_feature_reviews_path)
        expect(flash[:error]).to include('Please specify at least one app')
      end
    end
  end

  describe 'GET #search', :logged_in do
    let(:applications) { %w(frontend backend mobile) }
    let(:events) { [instance_double(Event)] }

    let(:projection) { instance_double(FeatureReviewSearchProjection) }
    let(:git_repository_loader) { instance_double(GitRepositoryLoader) }
    let(:repository) { instance_double(GitRepository) }

    before do
      allow(RepositoryLocation).to receive(:app_names).and_return(applications)
      allow(GitRepositoryLoader).to receive(:new).and_return(git_repository_loader)
      allow(FeatureReviewSearchProjection).to receive(:new).with(repository).and_return(projection)
      allow(Event).to receive(:in_order_of_creation).and_return(events)

      allow(git_repository_loader).to receive(:load).with('frontend').and_return(repository)
    end

    context 'when no search entered' do
      it 'it assigns links as empty' do
        get :search
        expect(assigns(:links)).to be_empty
        expect(assigns(:applications)).to eq(applications)
      end
    end

    context 'when search query submitted' do
      let(:expected_links) { ['/somelink'] }

      it 'assigns links for found Feature Reviews' do
        expect(projection).to receive(:apply_all).with(events).ordered
        expect(projection).to receive(:feature_reviews_for).with('abc123').and_return(expected_links).ordered

        get :search, version: 'abc123', application: 'frontend'

        expect(assigns(:links)).to eq(expected_links)
        expect(assigns(:applications)).to eq(applications)
      end
    end
  end
end
