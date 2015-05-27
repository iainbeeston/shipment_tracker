require 'git_repository'

class ReleasesProjection
  attr_reader :commits

  def initialize(per_page:, git_repository:)
    @per_page = per_page
    @git_repository = git_repository
    @releases_hash = {}
  end

  def apply_all(events)
    events.each { |e| apply(e) }
  end

  def apply(event)
    case event
    when JiraEvent
      update_release_hash_from_event(event)
    end
  end

  def commits
    @commits ||= @git_repository.recent_commits(@per_page)
  end

  def releases
    commits.map { |commit|
      Release.new(
        commit: commit,
        feature_review_path: @releases_hash.fetch(commit.id, {}).fetch(:path, nil),
      )
    }
  end

  private

  def update_release_hash_from_event(event)
    URI.extract(event.comment)
      .map { |comment_url| Addressable::URI.parse(comment_url) }
      .select { |uri| uri.path == '/feature_reviews' }
      .each { |uri|
        shas = extract_shas_from_uri(uri)
        shas.each do |sha|
          if commits.find { |c| c.id == sha }
            @releases_hash[sha] = { event: event, path: uri.request_uri }
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
