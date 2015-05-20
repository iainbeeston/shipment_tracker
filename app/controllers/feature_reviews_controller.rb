class FeatureReviewsController < ApplicationController
  def new
    @app_names = RepositoryLocation.app_names
  end

  def index
    @apps = apps
    @uat_url = params[:uat_url]
    @reports = build_reports
  end

  private

  def build_reports
    apps.map { |app_name, version|
      FeatureReviewProjection.new(app_name: app_name, version: version).tap do |report|
        report.apply_all(Event.in_order_of_creation)
      end
    }
  end

  def apps
    params.fetch(:apps, {}).select { |_name, version| version.present? }
  end
end
