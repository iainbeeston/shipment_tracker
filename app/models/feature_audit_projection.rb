require 'git_repository'

class FeatureAuditProjection
  def initialize(app_name:, from:, to:, git_repository: GitRepository)
    @app_name = app_name
    @from = from
    @to = to
    @git_repository = git_repository
  end

  def apply_all(events)
    events.each { |e| apply(e) }
  end

  def authors
    commits.map(&:author_name).uniq
  end

  def deploys
    deploys_for_app.map(&:details).map do |deploy|
      {
        server: deploy['server'],
        version: deploy['version'],
        deployed_at: Time.at(deploy['deployed_at']).strftime("%F %H:%M"),
        deployed_by: deploy['deployed_by'],
      }
    end
  end

  def builds
    CircleCiEvent.find_all_for_versions(shas) + JenkinsEvent.find_all_for_versions(shas)
  end

  def tickets
    @tickets ||= Set.new
  end

  private

  attr_reader :app_name, :from, :to, :git_repository

  def apply(event)
    case event
    when JiraEvent
      tickets.add(Ticket.from_jira_event(event)) if expected_tickets.include?(event.key)
    end
  end

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

  def expected_tickets
    @expected_tickets ||= commits.map { |commit| extract_tickets(commit.message) }.flatten.uniq
  end

  def extract_tickets(message)
    message.scan(/(?<=\b)[A-Z]{2,}-\d+(?=\b)/)
  end
end
