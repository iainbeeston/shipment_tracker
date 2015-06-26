class EventsController < ActionController::Metal
  include ActionController::Redirecting
  include AbstractController::Callbacks
  include Rails.application.routes.url_helpers
  include Authentication

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
      'jenkins'     => JenkinsEvent,
      'jira'        => JiraEvent,
      'manual_test' => ManualTestEvent,
      'uat'         => UatEvent,
    }.fetch(params[:type]) { |type| fail "Unrecognized event type '#{type}'" }
  end

  def path_from_url(url_or_path)
    return nil unless url_or_path.present?
    URI.parse('http://domain.com').merge(url_or_path).request_uri
  rescue URI::InvalidURIError
    nil
  end

  def logged_out_strategy
    self.status = 403
    self.response_body = 'Forbidden'
  end
end
