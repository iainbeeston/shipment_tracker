class CircleCi < Event
  def self.find_all_for_versions(versions)
    where("details -> 'payload' ->> 'vcs_revision' in (?)", versions)
  end
end
