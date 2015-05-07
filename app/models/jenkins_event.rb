class JenkinsEvent < Event
  def self.find_all_for_versions(versions)
    where("details -> 'build' -> 'scm' ->> 'commit' in (?)", versions)
  end

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
