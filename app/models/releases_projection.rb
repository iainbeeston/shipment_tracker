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
    events.each { |e| apply(e) }
  end

  def apply(event)
    case event
    when JiraEvent
      apply_jira_event(event)
    end
  end

  def commits
    @commits ||= @git_repository.recent_commits(@per_page)
  end

  def releases
    commits.map { |commit|
      release_hash = @releases_hash.fetch(commit.id, {})
      Release.new(
        commit: commit,
        feature_review_status: @tickets_hash.fetch(release_hash.fetch(:issue_id, nil), nil),
        feature_review_path: release_hash.fetch(:path, nil),
      )
    }
  end

  private

  def apply_jira_event(event)
    if @tickets_hash.key?(event.issue_id)
      @tickets_hash[event.issue_id] = event.status
    end

    URI.extract(event.comment)
      .map { |comment_url| Addressable::URI.parse(comment_url) }
      .select { |uri| uri.path == '/feature_reviews' }
      .each { |uri|
        shas = extract_shas_from_uri(uri)
        shas.each do |sha|
          if commits.find { |c| c.id == sha }
            @releases_hash[sha] = { issue_id: event.issue_id, path: uri.request_uri }
            @tickets_hash[event.issue_id] = event.status
          end
        end
      }
  end

  def extract_shas_from_uri(uri)
    uri.query_values
      .select { |key, _value| key.start_with?('apps[') }
      .values
      .reject(&:empty?)
  end
end
