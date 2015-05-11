class DeployEvent < Event
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
