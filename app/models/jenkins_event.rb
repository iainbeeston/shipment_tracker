class JenkinsEvent < Event
  def source
    "Jenkins"
  end

  def status
    status = details
             .fetch('build', {})
             .fetch('status', 'unknown').downcase

    status == 'failure' ? 'failed' : status
  end

  def version
    details
      .fetch('build', {})
      .fetch('scm', {})
      .fetch('commit', 'unknown')
  end
end
