class FeatureReviewsController < ApplicationController
  def new
    @app_names = RepositoryLocation.app_names
  end

  def index
    @apps = apps
  end

  private

  def apps
    params[:apps].select { |_name, version| version.present? }
  end
end