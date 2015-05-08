require 'git_repository'

class FeatureAuditProjection
  def initialize(app_name:, from:, to:, git_repository: GitRepository)
    @app_name = app_name
    @from = from
    @to = to
    @git_repository = git_repository
    @tickets_table = {}
  end

  def apply_all(events)
    events.each { |e| apply(e) }
  end

  def apply(event)
    case event
    when JiraEvent
      update_ticket_from_jira_event(event) if expected_ticket_keys.include?(event.key)
    end
  end

  def authors
    commits.map(&:author_name).uniq
  end

  def deploys
    deploys_for_app.map(&:details).map do |deploy|
      {
        server: deploy['server'],
        version: deploy['version'],
        deployed_by: deploy['deployed_by'],
      }
    end
  end

  def builds
    CircleCiEvent.find_all_for_versions(shas) + JenkinsEvent.find_all_for_versions(shas)
  end

  def tickets
    @tickets_table.values
  end

  private

  attr_reader :app_name, :from, :to, :git_repository

  def commits
    @commits ||= git_repository.commits_for(
      repository_name: app_name,
      from: from,
      to: to
    )
  end

  def shas
    commits.map(&:id)
  end

  def deploys_for_app
    DeployEvent.deploys_for_app(app_name).select { |deploy|
      shas.include?(deploy.details['version'])
    }
  end

  def expected_ticket_keys
    @expected_ticket_keys ||= commits.map { |commit| extract_ticket_keys(commit.message) }.flatten.uniq
  end

  def extract_ticket_keys(message)
    message.scan(/(?<=\b)[A-Z]{2,}-\d+(?=\b)/)
  end

  def update_ticket_from_jira_event(jira_event)
    new_attributes = {
      key: jira_event.key,
      summary: jira_event.summary,
      status: jira_event.status,
    }
    new_attributes[:approver_email] = jira_event.user_email if jira_event.status_changed_to?('Done')

    update_ticket(jira_event.key) do |ticket|
      ticket.update_attributes(new_attributes)
    end
  end

  def update_ticket(key, &block)
    ticket = @tickets_table.fetch(key, Ticket.new)
    @tickets_table[key] = block.call(ticket)
  end
end
