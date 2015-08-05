require 'forwardable'

module Projections
  class TicketsProjection
    def self.load(projection_url:, at:, repository: Repositories::TicketRepository.new)
      state = repository.tickets_for(projection_url: projection_url, at: at)
      new(
        projection_url: projection_url,
        tickets: state.fetch(:tickets),
      ).tap { |p| p.apply_all(state.fetch(:events)) }
    end

    def initialize(projection_url:, tickets: [])
      @projection_url = projection_url
      @tickets_table = tickets.map { |t| [t.key, t] }.to_h
    end

    def apply_all(events)
      events.each(&method(:apply))
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
end
