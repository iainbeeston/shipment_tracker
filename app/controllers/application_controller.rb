class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def git_loader
    @git_loader ||= Services::GitLoader.new(repositories: {}, dir: Dir.tmpdir)
  end
end
