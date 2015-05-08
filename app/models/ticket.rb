class Ticket
  include Virtus.value_object

  values do
    attribute :key, String
    attribute :summary, String
    attribute :status, String
  end

  def self.from_jira_event(jira_event)
    new(key: jira_event.key, summary: jira_event.summary, status: jira_event.status)
  end
end
