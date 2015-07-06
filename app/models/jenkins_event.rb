class JenkinsEvent < Event
  def source
    'Jenkins'
  end

  def success
    status = details
             .fetch('build', {})
             .fetch('status', nil)

    status == 'SUCCESS'
  end

  def version
    details
      .fetch('build', {})
      .fetch('scm', {})
      .fetch('commit', 'unknown')
  end
end
