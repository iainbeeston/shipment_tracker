module Repositories
  class FeatureReviewRepository
    def initialize
      @store = Snapshots::FeatureReview
      @count = Snapshots::EventCount
    end

    def feature_reviews_for(versions)
      store.where('versions && ARRAY[?]::varchar[]', versions).pluck(:url).to_set
    end

    def new_events
      Event.after_id(last_id)
    end

    def update
      apply_all(new_events)
    end

    private

    attr_reader :count, :store

    def last_id
      count.find_by_snapshot_name(snapshot_name).try(:event_id) || 0
    end

    def apply_all(events)
      ActiveRecord::Base.transaction do
        last_id = 0
        events.each do |event|
          last_id = event.id
          next unless event.is_a?(JiraEvent) && event.issue?

          locations(event.comment).each do |location|
            store.create(location)
          end
        end
        update_count last_id
      end
    end

    def locations(text)
      FeatureReviewLocation.from_text(text).map { |location|
        {
          url: location.url,
          versions: location.versions,
        }
      }
    end

    def update_count(id)
      record = count.find_or_create_by(snapshot_name: snapshot_name)
      record.event_id = id
      record.save!
    end

    def snapshot_name
      store.table_name
    end
  end
end
