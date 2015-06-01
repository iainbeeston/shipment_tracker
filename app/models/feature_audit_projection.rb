require 'git_repository'

class FeatureAuditProjection
  attr_reader :deploys, :builds, :comments, :from, :to

  def initialize(from:, to:, git_repository:)
    @from = from
    @to = to
    @git_repository = git_repository
    @tickets_projection = TicketsProjection.new
    @deploys = []
    @builds = []
    @comments = []
  end

  def apply_all(events)
    events.each { |e| apply(e) }
  end

  def apply(event)
    case event
    when JiraEvent
      tickets_projection.apply(event) if expected_ticket_keys.include?(event.key)
    when DeployEvent
      record_deploy(event)
    when CircleCiEvent, JenkinsEvent
      record_build(event)
    when CommentEvent
      record_comment(event)
    end
  end

  def authors
    commits.map(&:author_name).uniq
  end

  delegate :tickets, to: :tickets_projection

  def valid?
    commits.any?
  end

  private

  attr_reader :git_repository, :tickets_projection

  def commits
    @commits ||= to ? git_repository.commits_between(from, to) : []
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

  def record_comment(comment_event)
    @comments << comment_event if shas.include?(comment_event.version)
  end

  def build_from_event(build_event)
    Build.new(source: build_event.source, status: build_event.status, version: build_event.version)
  end
end
