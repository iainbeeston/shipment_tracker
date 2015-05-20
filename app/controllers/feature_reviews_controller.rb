class FeatureReviewsController < ApplicationController
  def new
    @app_names = RepositoryLocation.app_names
  end

  def index
    @apps = apps
    @uat_url = params[:uat_url]
    @projection = FeatureReviewProjection.new(apps)
    @projection.apply_all(Event.in_order_of_creation)
  end

  private

  def apps
    params.fetch(:apps, {}).select { |_name, version| version.present? }
  end
end
