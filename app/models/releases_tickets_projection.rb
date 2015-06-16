class ReleasesTicketsProjection
  def initialize
    @tickets_table = {}
  end

  def apply(event)
    return unless event.is_a?(JiraEvent) && event.issue?

    new_attributes = { key: event.key, summary: event.summary, status: event.status }

    approver_attributes = if event.approval?
                            { approver_email: event.user_email, approved_at: event.updated }
                          elsif event.unapproval?
                            { approver_email: nil, approved_at: nil }
                          else
                            {}
                          end

    update_ticket(event.key, new_attributes.merge(approver_attributes))
  end

  def tickets
    @tickets_table.values
  end

  def ticket_for(jira_key)
    @tickets_table[jira_key]
  end

  private

  def update_ticket(key, attributes)
    ticket = @tickets_table.fetch(key, Ticket.new)
    @tickets_table[key] = ticket.update_attributes(attributes)
  end
end
