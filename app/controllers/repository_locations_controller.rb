class RepositoryLocationsController < ApplicationController
  def index
    @new_repository_location = RepositoryLocation.new
    @repository_locations = RepositoryLocation.all
  end

  def create
    RepositoryLocation.create(params.require(:repository_location).permit(:name, :uri))
    redirect_to :repository_locations
  end
end
