module Repositories
  class FeatureReviewRepository
    def initialize
      @store = Snapshots::FeatureReview
      @synchronizer = CountSynchronizer.new(store.table_name, Snapshots::EventCount)
    end

    def feature_reviews_for(versions)
      store.where('versions && ARRAY[?]::varchar[]', versions).pluck(:url).to_set
    end

    delegate :new_events, to: :synchronizer

    def update
      synchronizer.update do |event|
        next unless event.is_a?(JiraEvent) && event.issue?

        locations(event.comment).each do |location|
          store.create(location)
        end
      end
    end

    private

    attr_reader :synchronizer, :store

    def locations(text)
      FeatureReviewLocation.from_text(text).map { |location|
        { url: location.url, versions: location.versions }
      }
    end
  end
end
