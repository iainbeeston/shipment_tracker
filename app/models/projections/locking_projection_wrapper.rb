module Projections
  class LockingProjectionWrapper
    def initialize(projection:, projection_url:, projection_locked: nil)
      @projection_url = projection_url

      @projection = projection
      @projection_locked = projection_locked

      @locks = {}
    end

    def apply(event)
      was_unlocked = unlocked?

      @projection.apply(event)
      update_locks(event)

      @projection_locked = @projection.clone if was_unlocked && locked?
    end

    def method_missing(method_name, *arguments, &block)
      if active_projection.respond_to?(method_name)
        active_projection.public_send(method_name, *arguments, &block)
      else
        super
      end
    end

    def respond_to?(method_name, include_private = false)
      active_projection.respond_to?(method_name) || super
    end

    def locked?
      locks.any? && locks.all?
    end

    def unlocked?
      !locked?
    end

    private

    def active_projection
      locked? ? @projection_locked : @projection
    end

    def locks
      @locks.values
    end

    def update_locks(event)
      return unless event.is_a?(JiraEvent) && event.issue?
      return unless @locks.key?(event.key) || matches_projection_url?(event.comment)

      @locks[event.key] = Rails.application.config.approved_statuses.include?(event.status) if event.status
    end

    def matches_projection_url?(comment)
      URI.extract(comment).any? { |comment_url|
        extract_path(comment_url) == extract_path(@projection_url)
      }
    end

    def extract_path(url_string)
      Addressable::URI.parse(url_string).normalize.request_uri
    end
  end
end
