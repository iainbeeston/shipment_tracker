class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :require_login

  include SessionsHelper

  def require_login
    redirect_to login_url if session[:current_user].nil?
  end

  def git_repository_loader
    @git_repository_loader ||= GitRepositoryLoader.from_rails_config
  end
end
