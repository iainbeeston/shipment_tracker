require 'feature_review_location'
require 'events/jira_event'
require 'snapshots/feature_review'

module Repositories
  class FeatureReviewRepository
    def initialize(store = Snapshots::FeatureReview)
      @store = store
    end

    delegate :table_name, to: :store

    def feature_reviews_for(versions)
      store.where('versions && ARRAY[?]::varchar[]', versions).group_by(&:url).map { |_, snapshots|
        latest_snapshot = snapshots.max(&:event_created_at)
        FeatureReview.new(
          url: latest_snapshot.url,
          versions: latest_snapshot.versions,
        )
      }
    end

    def apply(event)
      return unless event.is_a?(Events::JiraEvent) && event.issue?

      FeatureReviewLocation.from_text(event.comment).each do |location|
        store.create!(
          url: location.url,
          versions: location.versions,
          event_created_at: event.created_at,
        )
      end
    end

    private

    attr_reader :store
  end
end
