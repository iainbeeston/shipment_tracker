class GitRepositoryLocationsController < ApplicationController
  def index
    @new_git_repository_location = GitRepositoryLocation.new
    @git_repository_locations = GitRepositoryLocation.all
  end

  def create
    GitRepositoryLocation.create(params.require(:git_repository_location).permit(:name, :uri))
    redirect_to :git_repository_locations
  end
end
