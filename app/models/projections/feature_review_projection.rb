require 'addressable/uri'

module Projections
  class FeatureReviewProjection
    def self.build(projection_url)
      feature_review_location = FeatureReviewLocation.new(projection_url)
      new(
        uat_url: feature_review_location.uat_url,
        apps: feature_review_location.app_versions,
        builds_projection: LockingBuildsProjection.new(feature_review_location),
        deploys_projection: LockingDeploysProjection.new(feature_review_location),
        manual_tests_projection: LockingManualTestsProjection.new(feature_review_location),
        tickets_projection: LockingTicketsProjection.new(feature_review_location),
        uatests_projection: LockingUatestsProjection.new(feature_review_location),
      )
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

    def locked?
      @tickets_projection.locked?
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
