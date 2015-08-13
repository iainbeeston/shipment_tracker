require 'event'

class DeployEvent < Event
  def app_name
    details.fetch('app_name', nil).try(:downcase)
  end

  def server
    servers.first
  end

  def version
    details.fetch('version', nil)
  end

  def deployed_by
    details.fetch('deployed_by', nil)
  end

  def environment
    details.fetch('environment', nil)
  end

  private

  def servers
    details.fetch('servers', servers_fallback)
  end

  def servers_fallback
    [details.fetch('server', nil)].compact
  end
end
