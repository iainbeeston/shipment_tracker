class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def git_repository_loader
    @git_repository_loader ||= GitRepositoryLoader.new(
      ssh_key:  ENV['SSH_KEY'],
      ssh_user: ENV['SSH_USER'],
    )
  end
end
