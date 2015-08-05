require 'forwardable'

module Projections
  class DeploysProjection
    def self.load(apps: nil, server:, at: nil, repository: Repositories::DeployRepository.new)
      state = repository.deploys_for(apps: apps, server: server, at: at)
      new(
        apps: apps,
        server: server,
        deploys: state.fetch(:deploys),
      ).tap { |p| p.apply_all(state.fetch(:events)) }
    end

    def initialize(apps:, server:, deploys: [])
      @apps = apps
      @server = server
      @deploys_table = Hash[deploys.map { |d| [d.app_name, d] }]
    end

    def apply_all(events)
      events.each(&method(:apply))
    end

    def deploys
      deploys_table.values
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
