class FeatureReviewProjection
  attr_reader :builds

  def initialize(apps:, uat_url:)
    @apps = apps
    @uat_url = uat_url
    @builds = {}
    @deploys = {}
  end

  def apply_all(events)
    events.each do |event|
      apply(event)
    end
  end

  def deploys
    @deploys.values
  end

  private

  def apply(event)
    case event
    when CircleCiEvent, JenkinsEvent
      apply_build_event(event)
    when DeployEvent
      apply_deploy_event(event)
    end
  end

  def apply_build_event(build_event)
    app = versions[build_event.version]
    return unless app

    build = Build.new(
      source: build_event.source,
      status: build_event.status,
      version: build_event.version,
    )
    @builds[app] = @builds.fetch(app, []).push(build)
  end

  def apply_deploy_event(deploy_event)
    return unless deploy_event.server == @uat_url

    deploy = Deploy.new(
      app_name: deploy_event.app_name,
      server: deploy_event.server,
      version: deploy_event.version,
      deployed_by: deploy_event.deployed_by,
      correct: version_correctness_for_event(deploy_event),
    )
    @deploys[deploy_event.app_name] = deploy
  end

  def versions
    @versions ||= @apps.invert
  end

  def version_correctness_for_event(event)
    return :ignore unless @apps.key?(event.app_name)
    event.version == @apps[event.app_name] ? :yes : :no
  end
end
