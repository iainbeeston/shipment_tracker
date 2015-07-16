module Projections
  class FeatureReviewSearchProjection
    attr_reader :feature_reviews

    def initialize(git_repository:, version:)
      @git_repository = git_repository
      @versions = resolve_versions(version)
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

    attr_reader :git_repository, :versions

    def resolve(version)
      return version unless git_repository.merge?(version)
      git_repository.branch_parent(version)
    end

    def resolve_versions(version)
      return [] unless git_repository.exists?(version)

      resolved_version = resolve(version)
      [resolved_version] + child_versions(resolved_version)
    end

    def add_feature_reviews(feature_reviews)
      @feature_reviews.merge(feature_reviews)
    end

    def child_versions(version)
      git_repository.get_descendant_commits_of_branch(version).map(&:id)
    end
  end
end
