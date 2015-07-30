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

    private

    def app_under_review?(name)
      apps.key?(name)
    end

    attr_reader :server, :apps, :deploys_table

    def version_correctness_for_event(event)
      event.version == apps[event.app_name]
    end
  end
end
