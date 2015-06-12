class FeatureReviewsController < ApplicationController
  def new
    @app_names = RepositoryLocation.app_names
  end

  def index
    @return_to = request.original_fullpath

    @apps = apps
    @uat_url = params[:uat_url]

    if @apps.empty?
      flash[:error] = 'Please specify at least one app'
      return redirect_to new_feature_review_path
    end

    projection = FeatureReviewProjection.new(
      apps: @apps,
      uat_url: @uat_url,
      projection_url: request.original_url,
    )
    freezable_projection = FreezableProjection.new(projection)
    freezable_projection.apply_all(Event.in_order_of_creation)

    @presenter = FeatureReviewPresenter.new(freezable_projection)
  end

  private

  def apps
    params.fetch(:apps, {}).select { |_name, version| version.present? }
  end
end
