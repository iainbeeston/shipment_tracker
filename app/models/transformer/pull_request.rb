module Transformer
  class PullRequest
    def initialize(git_repository)
      @git_repository = git_repository
      @feature_review_locations = Set.new
    end

    def apply_all(events)
      events.each(&method(:apply))
    end

    def apply(event)
      return unless event.is_a?(JiraEvent) && event.issue?
      add_feature_review_locations(FeatureReviewLocation.from_text(event.comment))
    end

    def feature_reviews_for(version)
      resolved_version = resolve(version)
      versions = [resolved_version] + child_versions(resolved_version)
      feature_review_locations.select { |location| (location.versions & versions).any? }.map(&:url)
    end

    private

    attr_reader :feature_review_locations, :git_repository

    def resolve(version)
      return version unless git_repository.merge?(version)
      git_repository.branch_parent(version)
    end

    def add_feature_review_locations(locations)
      @feature_review_locations.merge(locations)
    end

    def child_versions(version)
      git_repository.get_descendant_commits_of_branch(version).map(&:id)
    end
  end
end
