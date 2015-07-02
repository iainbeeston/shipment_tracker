class UatEvent < Event
  def test_suite_version
    details.fetch('test_suite_version')
  end

  def server
    details.fetch('server')
  end

  def success
    details.fetch('success')
  end
end
