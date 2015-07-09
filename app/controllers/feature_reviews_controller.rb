class FeatureReviewsController < ApplicationController
  def new
    @app_names = RepositoryLocation.app_names
  end

  def show
    @return_to = request.original_fullpath

    @apps = apps
    uat_url = params[:uat_url]

    if @apps.empty?
      flash[:error] = 'Please specify at least one app'
      return redirect_to new_feature_reviews_path
    end

    projection = Projections::FeatureReviewProjection.build(
      apps: @apps,
      uat_url: uat_url,
      projection_url: request.original_url,
    )
    projection.apply_all(Event.in_order_of_creation)

    @presenter = FeatureReviewPresenter.new(projection)
  end

  def search
    @links = []
    @applications = RepositoryLocation.app_names
    @version = params[:version]
    @application = params[:application]

    return unless @version && @application

    projection = Projections::FeatureReviewSearchProjection.new(git_repository_for(@application))
    projection.apply_all(Event.in_order_of_creation)

    @links = projection.feature_reviews_for(@version)
    flash[:error] = 'No Feature Reviews found.' if @links.empty?
  end

  private

  def apps
    params.fetch(:apps, {}).select { |_name, version| version.present? }
  end

  def git_repository_for(app_name)
    git_repository_loader.load(app_name)
  end
end
