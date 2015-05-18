class IssueAuditProjection
  attr_reader :ticket, :builds, :app_name

  def initialize(app_name:, issue_name:, git_repository:)
    @app_name = app_name
    @issue_name = issue_name
    @git_repository = git_repository

    @ticket = nil
    @builds = []
  end

  def apply_all(events)
    events.each { |e| apply(e) }
  end

  def apply(event)
    case event
    when JiraEvent
      update_ticket_from_jira_event(event)
    when CircleCiEvent, JenkinsEvent
      record_build(event)
    end
  end

  def authors
    commits.map(&:author_name).uniq
  end

  def valid?
    ticket && commits.any?
  end

  private

  attr_reader :git_repository, :issue_name

  def commits
    @commits ||= git_repository.unmerged_commits_matching_query(issue_name)
  end

  def shas
    commits.map(&:id)
  end

  def update_ticket_from_jira_event(jira_event)
    return unless issue_name == jira_event.key

    new_attributes = { key: jira_event.key, summary: jira_event.summary, status: jira_event.status }

    if jira_event.status_changed?
      approver_attributes = if jira_event.status == 'Done'
                              { approver_email: jira_event.user_email, approved_at: jira_event.updated }
                            else
                              { approver_email: nil, approved_at: nil }
                            end
      new_attributes.merge!(approver_attributes)
    end

    @ticket ||= Ticket.new
    @ticket = @ticket.update_attributes(new_attributes)
  end

  def record_build(build_event)
    last_commit = git_repository.last_unmerged_commit_matching_query(issue_name)
    @builds << build_from_event(build_event) if last_commit && last_commit.id == build_event.version
  end

  def build_from_event(build_event)
    Build.new(source: build_event.source, status: build_event.status, version: build_event.version)
  end
end
