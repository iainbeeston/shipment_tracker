class EventsController < ApplicationController
  def create
    event_factory.create(params[:type], request.request_parameters, current_user)

    redirect_to redirect_path if redirect_path
    self.response_body = 'ok'
  end

  private

  def redirect_path
    @redirect_path ||= path_from_url(params[:return_to])
  end

  def path_from_url(url_or_path)
    return nil unless url_or_path.present?
    URI.parse('http://domain.com').merge(url_or_path).request_uri
  rescue URI::InvalidURIError
    nil
  end

  def unauthenticated_strategy
    self.status = 403
    self.response_body = 'Forbidden'
  end
end
