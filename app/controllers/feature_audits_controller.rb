class FeatureAuditsController < ApplicationController
  def show
    @return_to = request.original_fullpath

    projection = build_projection(Event.in_order_of_creation)

    @to_version = projection.to
    @authors = projection.authors
    @builds = projection.builds
    @comments = projection.comments
    @deploys = projection.deploys
    @tickets = projection.tickets

    @valid = projection.valid?
  rescue GitRepository::CommitNotFound => e
    flash[:error] = "Commit '#{e.message}' could not be found in #{app_name}"
  rescue GitRepository::CommitNotValid => e
    flash[:error] = "Commit '#{e.message}' is not valid"
  end

  private

  def build_projection(events)
    FeatureAuditProjection.new(
      app_name: app_name,
      from: clean_params[:from],
      to: clean_params[:to]
    ).tap do |projection|
      projection.apply_all(events)
    end
  end

  def app_name
    clean_params[:id]
  end

  def clean_params
    @clean_params ||= params.select { |_k, v| v.present? }
  end
end
