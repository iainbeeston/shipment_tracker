require 'jira_event'
require 'snapshots/ticket'
require 'ticket'

require 'addressable/uri'
require 'uri'

module Repositories
  class TicketRepository
    def initialize(store = Snapshots::Ticket)
      @store = store
    end

    delegate :table_name, to: :store

    def tickets_for(projection_url:, at: nil)
      tickets(projection_url, at)
    end

    def apply(event)
      return unless event.is_a?(JiraEvent) && event.issue?

      last_ticket = (store.where(key: event.key).last.try(:attributes) || {}).except('id')

      new_ticket = last_ticket.merge(
        'key' => event.key,
        'summary' => event.summary,
        'status' => event.status,
        'urls' => merge_ticket_urls(last_ticket, event),
        'event_created_at' => event.created_at,
      )

      store.create!(new_ticket)
    end

    private

    attr_reader :store

    def tickets(projection_url, at)
      query = at ? store.arel_table['event_created_at'].lteq(at) : nil
      store
        .select('DISTINCT ON (key) *')
        .where('urls @> ARRAY[?]', prepare_url(projection_url))
        .where(query)
        .order('key, id DESC')
        .map { |t| Ticket.new(t.attributes) }
    end

    def merge_ticket_urls(ticket, event)
      old_urls = ticket.fetch('urls', [])
      new_urls = projection_urls(event.comment)
      old_urls.concat(new_urls).uniq
    end

    def prepare_url(url_string)
      Addressable::URI.parse(url_string).normalize.to_s
    end

    def projection_urls(comment)
      FeatureReviewLocation.from_text(comment).map { |frl| prepare_url(frl.url) }
    end
  end
end
