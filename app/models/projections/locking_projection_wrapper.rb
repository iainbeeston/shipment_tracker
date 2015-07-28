module Projections
  class LockingProjectionWrapper
    def initialize(projection, projection_url)
      @projection = projection
      @projection_url = projection_url
      @events_queue = []
      @tickets_table = {}
    end

    def apply(event)
      if locked? && !_unlocking_event?(event)
        _queue_event(event)
      else
        _apply_queued_events_to_projection
        _apply_event_to_projection(event)
      end
    end

    def method_missing(method_name, *arguments, &block)
      if @projection.respond_to?(method_name)
        @projection.public_send(method_name, *arguments, &block)
      else
        super
      end
    end

    def respond_to?(method_name, include_private = false)
      @projection.respond_to?(method_name) || super
    end

    def locked?
      _tickets.present? && _tickets.all?(&:approved?)
    end

    private

    def _tickets
      @tickets_table.values
    end

    def _unlocking_event?(event)
      event.is_a?(JiraEvent) && event.unapproval?
    end

    def _queue_event(event)
      @events_queue << event
    end

    def _apply_queued_events_to_projection
      @events_queue.each do |queued_event|
        _apply_event_to_projection(queued_event)
      end
      @events_queue = []
    end

    def _apply_event_to_projection(event)
      @projection.apply(event)

      return unless event.is_a?(JiraEvent)
      return unless event.issue?
      return unless @tickets_table.key?(event.key) || _matches_projection_url?(event.comment)

      ticket = Ticket.new(
        key: event.key,
        summary: event.summary,
        status: event.status,
      )
      @tickets_table[event.key] = ticket
    end

    def _matches_projection_url?(comment)
      URI.extract(comment).any? { |comment_url|
        _extract_path(comment_url) == _extract_path(@projection_url)
      }
    end

    def _extract_path(url_string)
      Addressable::URI.parse(url_string).normalize.request_uri
    end
  end
end
