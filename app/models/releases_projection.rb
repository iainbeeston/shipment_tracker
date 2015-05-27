require 'git_repository'

class ReleasesProjection
  attr_reader :commits

  def initialize(per_page:, git_repository:)
    @per_page = per_page
    @git_repository = git_repository
    @commits = []
  end

  def apply_all(_events)
    # events.each { |e| apply(e) }
  end

  # def apply(event)
  # case event
  # when JiraEvent
  #   update_ticket_from_jira_event(event)
  # when DeployEvent
  #   record_deploy(event)
  # when CircleCiEvent, JenkinsEvent
  #   record_build(event)
  # when CommentEvent
  #   record_comment(event)
  # end
  # end

  def releases
    @git_repository.recent_commits(@per_page)
  end
end
