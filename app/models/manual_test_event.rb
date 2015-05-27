class ManualTestEvent < Event
  def apps
    details.fetch('testing_environment', {}).fetch('apps', [])
  end

  def user_name
    details.fetch('user', {}).fetch('name', nil)
  end

  def status
    details['status']
  end
end
