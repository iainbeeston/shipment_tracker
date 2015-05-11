require 'git_repository'

class FeatureAuditProjection
  attr_reader :deploys, :builds

  def initialize(app_name:, from:, to:, git_repository: GitRepository)
    @app_name = app_name
    @from = from
    @to = to
    @git_repository = git_repository
    @tickets_table = {}
    @deploys = []
    @builds = []
  end

  def apply_all(events)
    events.each { |e| apply(e) }
  end

  def apply(event)
    case event
    when JiraEvent
      update_ticket_from_jira_event(event)
    when DeployEvent
      record_deploy(event)
    when CircleCiEvent, JenkinsEvent
      record_build(event)
    end
  end

  def authors
    commits.map(&:author_name).uniq
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

  def expected_ticket_keys
    @expected_ticket_keys ||= commits.map { |commit| extract_ticket_keys(commit.message) }.flatten.uniq
  end

  def extract_ticket_keys(message)
    message.scan(/(?<=\b)[A-Z]{2,}-\d+(?=\b)/)
  end

  def update_ticket_from_jira_event(jira_event)
    return unless expected_ticket_keys.include?(jira_event.key)

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

  def deploy_from_event(deploy_event)
    Deploy.new(server: deploy_event.server,
               version: deploy_event.version,
               deployed_by: deploy_event.deployed_by)
  end

  def record_deploy(deploy_event)
    @deploys << deploy_from_event(deploy_event) if shas.include?(deploy_event.details['version'])
  end

  def record_build(build_event)
    @builds << build_from_event(build_event) if shas.include?(build_event.version)
  end

  def build_from_event(build_event)
    Build.new(source: build_event.source, status: build_event.status, version: build_event.version)
  end
end
