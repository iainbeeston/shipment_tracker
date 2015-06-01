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
  end

  def apply(event)
    case event
    when JiraEvent
      associate_releases_with_feature_review(event)
      add_ticket(event.key, event.status) if ticket?(event.key)
    end
  end

  def commits
    @commits ||= @git_repository.recent_commits(@per_page)
  end

  def releases
    associate_dependent_releases_with_feature_review

    commits.map { |commit|
      feature_review = feature_review_for_commit(commit.id)
      Release.new(
        version: commit.id,
        time: commit.time,
        subject: commit.subject_line,
        feature_review_status: get_ticket(feature_review.fetch(:key)),
        feature_review_path: feature_review.fetch(:path),
        approved: true,
      )
    }
  end

  private

  def associate_dependent_releases_with_feature_review
    feature_review_commit_versions.each do |sha|
      @git_repository.get_dependent_commits(sha).each do |dependent_commit|
        @feature_reviews[dependent_commit.id] = @feature_reviews[sha]
      end
    end
  end

  def feature_review_commit_versions
    @feature_reviews.keys
  end

  def feature_review_for_commit(commit_oid)
    @feature_reviews.fetch(commit_oid, key: nil, path: nil)
  end

  def associate_feature_review(commit_oid, feature_review)
    @feature_reviews[commit_oid] = feature_review
  end

  def add_ticket(key, status)
    @tickets_hash[key] = status
  end

  def get_ticket(key)
    @tickets_hash.fetch(key, nil)
  end

  def ticket?(key)
    @tickets_hash.key?(key)
  end

  def associate_releases_with_feature_review(jira_event)
    FeatureReviewLocation.from_text(jira_event.comment).each do |location|
      commit_oids = extract_relevant_commit_from_location(location)
      commit_oids.each do |commit_oid|
        associate_feature_review(commit_oid, key: jira_event.key, path: location.path)

        add_ticket(jira_event.key, jira_event.status)
      end
    end
  end

  def extract_relevant_commit_from_location(feature_review_location)
    feature_review_location.versions.select { |commit_oid|
      commits.find { |c| c.id == commit_oid }
    }
  end
end