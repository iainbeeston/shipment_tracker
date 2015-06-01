require 'git_repository'

class ReleasesProjection
  attr_reader :commits

  def initialize(per_page:, git_repository:)
    @per_page = per_page
    @git_repository = git_repository
    @feature_reviews = {}
    @tickets_hash = {}
  end

  def apply_all(events)
    events.each do |event|
      apply(event)
    end

    associate_dependent_releases_with_feature_review
  end

  def apply(event)
    case event
    when JiraEvent
      update_ticket_status(event)
      associate_releases_with_feature_review(event)
    end
  end

  def commits
    @commits ||= @git_repository.recent_commits(@per_page)
  end

  def releases
    commits.map { |commit|
      feature_review = @feature_reviews.fetch(commit.id, null_feature_review)
      Release.new(
        version: commit.id,
        time: commit.time,
        subject: commit.subject_line,
        feature_review_status: @tickets_hash.fetch(feature_review.fetch(:issue_id), nil),
        feature_review_path: feature_review.fetch(:path),
        approved: true,
      )
    }
  end

  private

  def null_feature_review
    {
      issue_id: nil,
      path: nil,
    }
  end

  def associate_dependent_releases_with_feature_review
    @feature_reviews.keys.each do |sha|
      @git_repository.get_dependent_commits(sha).each do |dependent_commit|
        @feature_reviews[dependent_commit.id] = @feature_reviews[sha]
      end
    end
  end

  def update_ticket_status(jira_event)
    @tickets_hash[jira_event.issue_id] = jira_event.status if @tickets_hash.key?(jira_event.issue_id)
  end

  def associate_releases_with_feature_review(jira_event)
    FeatureReviewLocation.from_text(jira_event.comment).each do |location|
      commit_oids = extract_relevant_commit_from_location(location)
      commit_oids.each do |commit_oid|
        @feature_reviews[commit_oid] = { issue_id: jira_event.issue_id, path: location.path }
        @tickets_hash[jira_event.issue_id] = jira_event.status
      end
    end
  end

  def extract_relevant_commit_from_location(feature_review_location)
    feature_review_location.versions.select { |commit_oid|
      commits.find { |c| c.id == commit_oid }
    }
  end
end
