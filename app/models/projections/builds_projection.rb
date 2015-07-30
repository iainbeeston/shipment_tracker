require 'forwardable'

module Projections
  class BuildsProjection
    def initialize(apps:, builds_table: nil)
      @apps = apps
      @builds_table = builds_table || apps_hash_with_value(@apps, Build.new)
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

    def apps_hash_with_value(apps, value)
      apps.map { |key, _| [key, value] }.to_h
    end
  end
end
