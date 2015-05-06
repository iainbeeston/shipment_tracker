class CircleCi < Event
  def self.find_all_for_versions(versions)
    where("details -> 'payload' ->> 'vcs_revision' in (?)", versions)
  end

  def source
    self.class.to_s
  end

  def status
    details.fetch('payload', {}).fetch('outcome', 'unknown')
  end

  def version
    details.fetch('payload', {}).fetch('vcs_revision', 'unknown')
  end
end
