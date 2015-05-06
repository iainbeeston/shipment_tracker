class CircleCi < Event
  def self.find_all_for_versions(versions)
    where("details -> 'payload' ->> 'vcs_revision' in (?)", versions)
  end

  def source
    self.class.to_s
  end

  def status
    details['payload']['outcome']
  end

  def version
    details['payload']['vcs_revision']
  end
end
