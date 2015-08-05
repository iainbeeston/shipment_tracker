require 'forwardable'

module Projections
  class UatestsProjection
    def self.load(apps:, server:, at:, repository: Repositories::UatestRepository.new)
      state = repository.uatest_for(apps: apps, server: server, at: at)
      new(
        apps: apps,
        server: server,
        versions: state.fetch(:versions),
        uatest: state.fetch(:uatest),
      ).tap { |p| p.apply_all(state.fetch(:events)) }
    end

    attr_reader :uatest

    def initialize(apps:, server:, versions: {}, uatest: nil)
      @apps = apps
      @server = server
      @versions_on_uats = versions
      @uatest = uatest
    end

    def apply_all(events)
      events.each(&method(:apply))
    end

    def apply(event)
      case event
      when DeployEvent
        return unless event.server == server
        versions_on_uats[event.app_name] = event.version
      when UatEvent
        return unless correct_versions_deployed? && event.server == server
        @uatest = Uatest.new(
          success: event.success,
          test_suite_version: event.test_suite_version,
        )
      end
    end

    private

    attr_reader :server, :apps, :versions_on_uats

    def correct_versions_deployed?
      apps.all? { |app_name, expected_version|
        versions_on_uats[app_name] == expected_version
      }
    end
  end
end
