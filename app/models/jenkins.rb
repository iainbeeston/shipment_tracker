class Jenkins < Event
  def self.find_all_for_versions(versions)
    where("details -> 'build' -> 'scm' ->> 'commit' in (?)", versions)
  end

  def source
    self.class.to_s
  end

  def status
    details['build']['status'].downcase
  end

  def version
    details['build']['scm']['commit']
  end
end
