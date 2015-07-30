require 'forwardable'

module Projections
  class TicketsProjection
    def initialize(projection_url:, tickets_table: {})
      @projection_url = projection_url
      @tickets_table = tickets_table
    end

    def apply(event)
      return unless event.is_a?(JiraEvent)
      return unless event.issue?
      return unless @tickets_table.key?(event.key) || matches_projection_url?(event.comment)

      ticket = Ticket.new(
        key: event.key,
        summary: event.summary,
        status: event.status,
      )
      @tickets_table[event.key] = ticket
    end

    def tickets
      @tickets_table.values
    end

    def clone
      self.class.new(projection_url: @projection_url.clone, tickets_table: @tickets_table.clone)
    end

    private

    def matches_projection_url?(comment)
      URI.extract(comment).any? { |comment_url|
        extract_path(comment_url) == extract_path(@projection_url)
      }
    end

    def extract_path(url_string)
      Addressable::URI.parse(url_string).normalize.request_uri
    end
  end

  class LockingTicketsProjection
    extend Forwardable

    def initialize(feature_review_location)
      @projection = LockingProjectionWrapper.new(
        projection: TicketsProjection.new(projection_url: feature_review_location.url),
        projection_url: feature_review_location.url,
      )
    end

    def_delegators :@projection, :tickets, :apply, :locked?
  end
end
