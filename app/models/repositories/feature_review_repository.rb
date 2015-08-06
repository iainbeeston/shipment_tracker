require 'feature_review_location'
require 'jira_event'
require 'snapshots/feature_review'

module Repositories
  class FeatureReviewRepository
    def initialize(store = Snapshots::FeatureReview)
      @store = store
    end

    delegate :table_name, to: :store

    def feature_reviews_for(versions)
      store.where('versions && ARRAY[?]::varchar[]', versions).pluck(:url).to_set
    end

    def apply(event)
      return unless event.is_a?(JiraEvent) && event.issue?

      locations(event.comment).each do |location|
        store.create!(location)
      end
    end

    private

    attr_reader :store

    def locations(text)
      FeatureReviewLocation.from_text(text).map { |location|
        { url: location.url, versions: location.versions }
      }
    end
  end
end
