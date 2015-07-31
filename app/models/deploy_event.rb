class DeployEvent < Event
  def app_name
    details.fetch('app_name', nil).try(:downcase)
  end

  def server
    details.fetch('server', nil)
  end

  def version
    details.fetch('version', nil)
  end

  def deployed_by
    details.fetch('deployed_by', nil)
  end
end
