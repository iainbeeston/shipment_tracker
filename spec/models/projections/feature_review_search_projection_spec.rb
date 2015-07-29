require 'rails_helper'
require 'projections/feature_review_search_projection'

RSpec.describe Projections::FeatureReviewSearchProjection do
  describe '#feature_reviews' do
    it 'returns the feature review urls which match the versions' do
      events = [
        build(:jira_event, comment_body: "Review: #{feature_review_url(frontend: 'abc', backend: 'def')}"),
        build(:jira_event, comment_body: "Review: #{feature_review_url(frontend: 'ghi', backend: 'klm')}"),
        build(:jira_event, comment_body: "Review: #{feature_review_url(frontend: 'ghi', backend: 'nop')}"),
      ]

      results = Projections::FeatureReviewSearchProjection.new(
        versions: %w(abc nop xyz),
      ).tap { |projection|
        projection.apply_all(events)
      }.feature_reviews

      expect(results).to match_array([
        feature_review_url(frontend: 'abc', backend: 'def'),
        feature_review_url(frontend: 'ghi', backend: 'nop'),
      ])
    end
  end

  describe '.load' do
    let(:versions) { %w(abc def 123) }
    let(:feature_review_urls) { %w(http://foo http://bar) }
    let(:recent_events) { [Event.new] }
    let(:repository) { instance_double(Repositories::FeatureReviewRepository) }

    let(:expected_projection) { instance_double(Projections::FeatureReviewSearchProjection) }

    it 'inflates the projection and feeds it remaining events' do
      allow(repository).to receive(:feature_reviews_for).with(versions).and_return(feature_review_urls)
      allow(repository).to receive(:new_events).and_return(recent_events)

      allow(Projections::FeatureReviewSearchProjection).to receive(:new)
        .with(versions: versions, feature_reviews: feature_review_urls)
        .and_return(expected_projection)

      expect(expected_projection).to receive(:apply_all).with(recent_events)

      loaded_projection = Projections::FeatureReviewSearchProjection.load(
        versions: versions,
        repository: repository,
      )

      expect(loaded_projection).to equal(expected_projection)
    end
  end
end
