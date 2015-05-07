class JiraEvent < Event
  # def self.find_all_for_versions(versions)
  #   where("details -> 'payload' ->> 'vcs_revision' in (?)", versions)
  # end

  def key
    details.fetch('issue').fetch('key')
  end

  def summary
    details.fetch('issue').fetch('fields').fetch('summary')
  end
end
