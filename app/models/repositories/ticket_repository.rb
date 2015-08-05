module Repositories
  class TicketRepository
    def initialize
      @store = Snapshots::Ticket
      @synchronizer = CountSynchronizer.new(store.table_name, Snapshots::EventCount)
    end

    def tickets_for(projection_url:, at: nil)
      ActiveRecord::Base.transaction do
        {
          tickets: tickets(projection_url, at),
          events: synchronizer.new_events(up_to: at),
        }
      end
    end

    def update
      synchronizer.update do |event|
        next unless event.is_a?(JiraEvent) && event.issue?

        last_ticket = (store.where(key: event.key).last.try(:attributes) || {}).except('id')

        new_ticket = last_ticket.merge(
          'key' => event.key,
          'summary' => event.summary,
          'status' => event.status,
          'urls' => merge_ticket_urls(last_ticket, event),
          'event_created_at' => event.created_at,
        )

        store.create(new_ticket)
      end
    end

    private

    attr_reader :store, :synchronizer

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
      URI.extract(comment).map(&method(:prepare_url))
    end
  end
end
