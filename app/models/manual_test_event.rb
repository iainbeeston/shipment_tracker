class ManualTestEvent < Event
  def apps
    details.fetch('apps', [])
  end

  def email
    details.fetch('email', nil)
  end

  def comment
    details.fetch('comment', '')
  end

  def status
    details.fetch('status', nil)
  end
end
