class ReleasesController < ApplicationController
  def index
    @app_names = GitRepositoryLocation.app_names
  end

  def show
    projection = build_projection(Events::BaseEvent.in_order_of_creation)
    @pending_releases = projection.pending_releases
    @deployed_releases = projection.deployed_releases
    @app_name = app_name
  rescue GitRepositoryLoader::NotFound
    render text: 'Repository not found', status: :not_found
  end

  private

  def build_projection(events)
    Projections::ReleasesProjection.new(
      per_page: 50,
      git_repository: git_repository,
      app_name: app_name,
    ).tap do |projection|
      projection.apply_all(events)
    end
  end

  def app_name
    params[:id]
  end

  def git_repository
    git_repository_loader.load(app_name)
  end
end
