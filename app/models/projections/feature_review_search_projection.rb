module Projections
  class FeatureReviewSearchProjection
    attr_reader :feature_reviews

    def initialize(versions:)
      @versions = versions
      @feature_reviews = Set.new
    end

    def apply_all(events)
      events.each(&method(:apply))
    end

    def apply(event)
      return unless event.is_a?(JiraEvent) && event.issue?
      relevant_urls = FeatureReviewLocation.from_text(event.comment).select { |location|
        (location.versions & versions).any?
      }.map(&:url)
      add_feature_reviews(relevant_urls)
    end

    private

    attr_reader :versions

    def add_feature_reviews(feature_reviews)
      @feature_reviews.merge(feature_reviews)
    end
  end
end
