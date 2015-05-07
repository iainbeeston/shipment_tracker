class Ticket
  include Virtus.value_object

  values do
    attribute :key, String
  end

  attribute :summary, String

  def self.from_jira_event(jira_event)
    new(key: jira_event.key, summary: jira_event.summary)
  end
end
