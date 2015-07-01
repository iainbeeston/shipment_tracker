class UatEvent < Event
  def test_suite_version
    details.fetch('test_suite_version')
  end

  def server
    details.fetch('server')
  end

  def status
    details.fetch('status')
  end
end
