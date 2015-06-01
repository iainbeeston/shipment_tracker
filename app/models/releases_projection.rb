require 'git_repository'

class ReleasesProjection
  attr_reader :commits

  def initialize(per_page:, git_repository:)
    @per_page = per_page
    @git_repository = git_repository
    @releases_hash = {}
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

  def associate_dependent_releases_with_feature_review
    @releases_hash.keys.each do |sha|
      @git_repository.get_dependent_commits(sha).each do |dependent_commit|
        @releases_hash[dependent_commit.id] = @releases_hash[sha]
      end
    end
  end

  def releases
    commits.map { |commit|
      release_hash = @releases_hash.fetch(commit.id, {})
      Release.new(
        version: commit.id,
        time: commit.time,
        subject: commit.subject_line,
        feature_review_status: @tickets_hash.fetch(release_hash.fetch(:issue_id, nil), nil),
        feature_review_path: release_hash.fetch(:path, nil),
      )
    }
  end

  private

  def update_ticket_status(jira_event)
    @tickets_hash[jira_event.issue_id] = jira_event.status if @tickets_hash.key?(jira_event.issue_id)
  end

  def associate_releases_with_feature_review(jira_event)
    uris = extract_relevant_uris_from_comment(jira_event.comment)
    uris.each do |uri|
      commit_oids = extract_relevant_commit_oids_from_uri(uri)
      commit_oids.each do |commit_oid|
        @releases_hash[commit_oid] = { issue_id: jira_event.issue_id, path: uri.request_uri }
        @tickets_hash[jira_event.issue_id] = jira_event.status
      end
    end
  end

  def extract_relevant_uris_from_comment(comment)
    URI.extract(comment)
      .map { |comment_url| Addressable::URI.parse(comment_url) }
      .select { |uri| uri.path == '/feature_reviews' }
  end

  def extract_relevant_commit_oids_from_uri(uri)
    uri.query_values
      .select { |key, _value| key.start_with?('apps[') }
      .values
      .reject(&:empty?)
      .select { |commit_oid| commits.find { |c| c.id == commit_oid } }
  end
end
