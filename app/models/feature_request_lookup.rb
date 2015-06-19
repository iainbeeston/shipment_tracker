class FeatureRequestLookup
  def initialize(repo)
    @repo = repo
    @events = []
  end

  def apply(event)
    return unless event.is_a?(JiraEvent) && event.issue?
    @events << event
  end

  def feature_requests_for(sha)
    return [] unless @repo.exists?(sha)
    @events.flat_map do |event|
      locations = FeatureReviewLocation.from_text(event.comment).select { |location|
        location.versions.include?(sha)
      }
      locations.map(&:url)
    end
  end
end
