class IssueAuditProjection
  attr_reader :ticket, :authors, :builds, :deploys

  def initialize(app_name:, issue_name:, git_repository:)
    @app_name = app_name
    @issue_name = issue_name
    @git_repository = git_repository

    @ticket = Ticket.new
  end

  def apply_all(events)
    events.each { |e| apply(e) }
  end

  def apply(event)
    case event
    when JiraEvent
      update_ticket_from_jira_event(event)
    end
  end

  private

  def update_ticket_from_jira_event(jira_event)
    return unless @issue_name == jira_event.key

    new_attributes = { key: jira_event.key, summary: jira_event.summary, status: jira_event.status }

    if jira_event.status_changed?
      approver_attributes = if jira_event.status == 'Done'
                              { approver_email: jira_event.user_email, approved_at: jira_event.updated }
                            else
                              { approver_email: nil, approved_at: nil }
                            end
      new_attributes.merge!(approver_attributes)
    end

    @ticket = @ticket.update_attributes(new_attributes)
  end
end
