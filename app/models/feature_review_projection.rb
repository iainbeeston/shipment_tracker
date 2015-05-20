class FeatureReviewProjection
  attr_reader :builds

  def initialize(apps)
    @apps = apps
    @builds = {}
  end

  def apply_all(events)
    events.each do |event|
      apply(event)
    end
  end

  private

  def apply(event)
    case event
    when CircleCiEvent, JenkinsEvent
      app = versions[event.version]
      if app
        build = Build.new(source: event.source, status: event.status, version: event.version)
        @builds[app] = @builds.fetch(app, []).push(build)
      end
    end
  end

  def versions
    @versions ||= @apps.invert
  end
end
