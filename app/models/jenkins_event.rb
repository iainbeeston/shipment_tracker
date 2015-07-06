class JenkinsEvent < Event
  def source
    'Jenkins'
  end

  def success
    status = details
             .fetch('build', {})
             .fetch('status', 'unknown').downcase

    {
      'success' => true,
      'failure' => false,
    }[status]
  end

  def version
    details
      .fetch('build', {})
      .fetch('scm', {})
      .fetch('commit', 'unknown')
  end
end
