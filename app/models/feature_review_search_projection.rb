class FeatureReviewSearchProjection
  def initialize(git_repositories: [])
    @git_repositories = git_repositories
    @events = []
  end

  def apply(event)
    return unless event.is_a?(JiraEvent) && event.issue?
    @events << event
  end

  def feature_requests_for(sha)
    urls = []

    @git_repositories.each do |git_repository|
      next unless git_repository.exists?(sha)

      shas = [sha] + git_repository.get_descendant_commits_of_branch(sha).map(&:id)
      urls += @events.flat_map { |event|
        locations = FeatureReviewLocation.from_text(event.comment).select { |location|
          (location.versions & shas).present?  # Set intersection present?
        }
        locations.map(&:path)
      }
    end

    urls.uniq
  end
end
