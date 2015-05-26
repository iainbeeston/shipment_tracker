class ManualTestEvent < Event
  def apps
    details['testing_environment']['apps']
  end

  def user_name
    details['user']['name']
  end

  def status
    details['status']
  end
end
