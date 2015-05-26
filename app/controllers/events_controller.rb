class EventsController < ActionController::Metal
  include ActionController::Redirecting
  include Rails.application.routes.url_helpers

  def create
    event_type.create(details: request.request_parameters)

    redirect_to redirect_path if redirect_path
    self.response_body = 'ok'
  end

  private

  def redirect_path
    @redirect_path ||= path_from_url(params[:return_to])
  end

  def event_type
    {
      'deploy'      => DeployEvent,
      'circleci'    => CircleCiEvent,
      'comments'    => CommentEvent,
      'jenkins'     => JenkinsEvent,
      'jira'        => JiraEvent,
      'manual_test' => ManualTestEvent,
    }.fetch(params[:type])
  end

  def path_from_url(url_or_path)
    return nil unless url_or_path.present?
    URI.parse('http://domain.com').merge(url_or_path).request_uri
  rescue URI::InvalidURIError
    nil
  end
end
