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

    projection = FeatureReviewProjection.build(
      apps: @apps,
      uat_url: @uat_url,
      projection_url: request.original_url,
    )
    projection.apply_all(Event.in_order_of_creation)

    @presenter = FeatureReviewPresenter.new(projection)
  end

  def search
    @links = []
    return unless params[:version]
    projection = FeatureReviewSearchProjection.new(git_repositories: git_repositories)
    Event.in_order_of_creation.each do |event|
      projection.apply(event)
    end

    @links = projection.feature_requests_for(params[:version])
  end

  private

  def apps
    params.fetch(:apps, {}).select { |_name, version| version.present? }
  end

  def git_repositories
    repos  = []
    RepositoryLocation.all.map(&:name).each do |name|
      repos << git_repository_loader.load(name)
    end
    repos
  end
end
