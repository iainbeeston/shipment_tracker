require 'addressable/uri'

module Projections
  class FeatureReviewProjection
    def self.load(projection_url)
      feature_review_location = FeatureReviewLocation.new(projection_url)
      apps = feature_review_location.app_versions
      server = feature_review_location.uat_host
      new(
        uat_url: feature_review_location.uat_url,
        apps: feature_review_location.app_versions,
        builds_projection: BuildsProjection.new(apps: apps),
        deploys_projection: DeploysProjection.new(apps: apps, server: server),
        manual_tests_projection: ManualTestsProjection.new(apps: apps),
        tickets_projection: TicketsProjection.new(projection_url: feature_review_location.url),
        uatests_projection: UatestsProjection.new(apps: apps, server: server),
      ).tap do |projection|
        projection.apply_all(Event.in_order_of_creation)
      end
    end

    attr_reader :uat_url, :apps

    def initialize(builds_projection:, deploys_projection:, manual_tests_projection:, tickets_projection:,
                   uatests_projection:, uat_url:, apps:)
      @builds_projection = builds_projection
      @deploys_projection = deploys_projection
      @manual_tests_projection = manual_tests_projection
      @tickets_projection = tickets_projection
      @uatests_projection = uatests_projection
      @uat_url = uat_url
      @apps = apps
    end

    def apply_all(events)
      events.each do |event|
        apply(event)
      end
    end

    def apply(event)
      projections.each do |projection|
        projection.apply(event)
      end
    end

    def deploys
      @deploys_projection.deploys
    end

    def tickets
      @tickets_projection.tickets
    end

    def builds
      @builds_projection.builds
    end

    def qa_submission
      @manual_tests_projection.qa_submission
    end

    def uatest
      @uatests_projection.uatest
    end

    private

    def projections
      [
        @builds_projection,
        @deploys_projection,
        @tickets_projection,
        @manual_tests_projection,
        @uatests_projection,
      ]
    end
  end
end
