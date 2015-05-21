class DeployEvent < Event
  def app_name
    details['app_name']
  end

  def server
    details['server']
  end

  def version
    details['version']
  end

  def deployed_by
    details['deployed_by']
  end
end
