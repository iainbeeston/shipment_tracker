class GithubNotificationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    RepositoryLocation.update_from_github_notification(request.request_parameters)
    head :ok
  end

  private

  def unauthenticated_strategy
    self.status = 403
    self.response_body = 'Forbidden'
  end
end
