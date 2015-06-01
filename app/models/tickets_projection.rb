class TicketsProjection
  def initialize
    @tickets_table = {}
  end

  def apply(event)
    return unless event.is_a?(JiraEvent)

    new_attributes = { key: event.key, summary: event.summary, status: event.status }

    if event.status_changed?
      approver_attributes = if event.status == 'Done'
                              { approver_email: event.user_email, approved_at: event.updated }
                            else
                              { approver_email: nil, approved_at: nil }
                            end
      new_attributes.merge!(approver_attributes)
    end

    update_ticket(event.key) do |ticket|
      ticket.update_attributes(new_attributes)
    end
  end

  def tickets
    @tickets_table.values
  end

  def ticket_for(jira_key)
    @tickets_table[jira_key]
  end

  private

  def update_ticket(key, &block)
    ticket = @tickets_table.fetch(key, Ticket.new)
    @tickets_table[key] = block.call(ticket)
  end
end
