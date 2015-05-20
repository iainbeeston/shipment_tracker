class FeatureReviewProjection
  attr_reader :app_name, :version, :builds

  def initialize(app_name:, version:)
    @app_name = app_name
    @version = version
    @builds = []
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
      if event.version == version
        @builds << Build.new(source: event.source, status: event.status, version: event.version)
      end
    end
  end
end
