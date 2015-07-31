class UatEvent < Event
  def test_suite_version
    details.fetch('test_suite_version', nil)
  end

  def server
    details.fetch('server', nil)
  end

  def success
    details.fetch('success', false)
  end
end
