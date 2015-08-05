require 'forwardable'

module Projections
  class BuildsProjection
    def self.load(apps:, at: nil, repository: Repositories::BuildRepository.new)
      state = repository.builds_for(apps: apps, at: at)
      new(
        apps: apps,
        builds: state.fetch(:builds),
      ).tap { |p| p.apply_all(state.fetch(:events)) }
    end

    def initialize(apps:, builds: [])
      @apps = apps
      @builds_table = default_builds_table.merge(builds_table_for(builds))
    end

    def apply_all(events)
      events.each(&method(:apply))
    end

    def apply(event)
      return unless event.is_a?(CircleCiEvent) || event.is_a?(JenkinsEvent)
      app = versions[event.version]
      return unless app

      build = Build.new(
        source: event.source,
        success: event.success,
        version: event.version,
      )
      @builds_table[app] = build
    end

    def builds
      @builds_table
    end

    private

    def versions
      @versions ||= @apps.invert
    end

    def builds_table_for(builds)
      builds.map { |b| [versions[b.version], b] }.to_h
    end

    def app_names
      @apps.keys
    end

    def default_builds_table
      app_names.map { |name, _| [name, Build.new] }.to_h
    end
  end
end
