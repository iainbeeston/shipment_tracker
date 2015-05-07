class EventsController < ActionController::Metal
  def create
    event_type.create(details: request.request_parameters)
    self.response_body = "ok"
  end

  private

  def event_type
    {
      'deploy'   => DeployEvent,
      'circleci' => CircleCiEvent,
      'jenkins'  => JenkinsEvent,
      'jira'     => JiraEvent,
    }.fetch(params[:type])
  end
end
