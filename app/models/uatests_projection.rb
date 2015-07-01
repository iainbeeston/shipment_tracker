class UatestsProjection
  attr_reader :uatests

  def initialize(apps:, server:)
    @apps = apps
    @server = server
    @versions_on_uats = {}
    @uatests = nil
  end

  def apply(event)
    case event
    when DeployEvent
      return unless event.server == server
      versions_on_uats[event.app_name] = event.version
    when UatEvent
      return unless correct_versions_deployed? && event.server == server
      @uatests = Uatests.new(
        status: event.status,
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
