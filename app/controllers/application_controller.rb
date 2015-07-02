class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Authentication
  helper_method :login_url, :current_user

  def git_repository_loader
    @git_repository_loader ||= GitRepositoryLoader.from_rails_config
  end

  def event_factory
    @event_factory ||= EventFactory.build
  end
end
