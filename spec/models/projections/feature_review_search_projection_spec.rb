require 'rails_helper'
require 'projections/feature_review_search_projection'

RSpec.describe Projections::FeatureReviewSearchProjection do
  describe '#feature_reviews' do
    it 'returns the feature review urls which match the versions' do
      events = [
        build(:jira_event, comment_body: "Here you go: #{url_for(frontend: 'abc', backend: 'def')}"),
        build(:jira_event, comment_body: "Here you go: #{url_for(frontend: 'ghi', backend: 'klm')}"),
        build(:jira_event, comment_body: "Here you go: #{url_for(frontend: 'ghi', backend: 'nop')}"),
      ]

      results = Projections::FeatureReviewSearchProjection.new(
        versions: %w(abc nop xyz),
      ).tap { |projection|
        projection.apply_all(events)
      }.feature_reviews

      expect(results).to match_array([
        url_for(frontend: 'abc', backend: 'def'),
        url_for(frontend: 'ghi', backend: 'nop'),
      ])
    end
  end

  private

  def url_for(apps)
    Support::FeatureReviewUrl.new.build(apps)
  end
end
