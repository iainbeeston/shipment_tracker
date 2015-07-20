class GithubNotificationsController < ApplicationController
  skip_before_action :require_authentication

  def create
    RepositoryLocation.update_from_github_notification(request.request_parameters)
    head :ok
  end
end
