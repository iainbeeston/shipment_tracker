require 'forwardable'

module Projections
  class DeploysProjection
    def initialize(apps:, server:, deploys_table: {})
      @apps = apps
      @server = server
      @deploys_table = deploys_table
    end

    def apply(event)
      return unless event.is_a?(DeployEvent)
      return unless event.server == server && app_under_review?(event.app_name)

      deploy = Deploy.new(
        app_name: event.app_name,
        server: event.server,
        version: event.version,
        deployed_by: event.deployed_by,
        correct: version_correctness_for_event(event),
      )
      deploys_table[event.app_name] = deploy
    end

    def deploys
      deploys_table.values
    end

    def clone
      self.class.new(apps: @apps.clone, server: @server.clone, deploys_table: @deploys_table.clone)
    end

    private

    def app_under_review?(name)
      apps.key?(name)
    end

    attr_reader :server, :apps, :deploys_table

    def version_correctness_for_event(event)
      event.version == apps[event.app_name]
    end
  end

  class LockingDeploysProjection
    extend Forwardable

    def initialize(feature_review_location)
      @projection = LockingProjectionWrapper.new(
        projection: DeploysProjection.new(
          apps: feature_review_location.app_versions,
          server: feature_review_location.uat_host,
        ),
        projection_url: feature_review_location.url,
      )
    end

    def_delegators :@projection, :deploys, :apply
  end
end
