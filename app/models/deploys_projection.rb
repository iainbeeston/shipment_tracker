class DeploysProjection
  def initialize(apps:, uat_url:)
    @apps = apps
    @uat_url = uat_url
    @deploys_table = {}
  end

  def apply(event)
    return unless event.is_a?(DeployEvent)
    return unless event.server == @uat_url && @apps.key?(event.app_name)

    deploy = Deploy.new(
      app_name: event.app_name,
      server: event.server,
      version: event.version,
      deployed_by: event.deployed_by,
      correct: version_correctness_for_event(event),
    )
    @deploys_table[event.app_name] = deploy
  end

  def deploys
    @deploys_table.values
  end

  private

  def version_correctness_for_event(event)
    event.version == @apps[event.app_name] ? :yes : :no
  end
end
