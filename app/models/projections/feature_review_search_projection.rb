module Projections
  class FeatureReviewSearchProjection
    attr_reader :feature_reviews

    def self.load(versions:, repository: Repositories::FeatureReviewRepository.new)
      new(
        versions: versions,
        feature_reviews: repository.feature_reviews_for(versions),
      ).tap do |projection|
        projection.apply_all(Event.after_id(repository.last_id))
      end
    end

    def initialize(versions:, feature_reviews: Set.new)
      @versions = versions
      @feature_reviews = feature_reviews
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
