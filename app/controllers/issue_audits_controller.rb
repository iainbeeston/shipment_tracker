class IssueAuditsController < ApplicationController
  def index
    redirect_to issue_audit_path(params[:issue_name]) if params[:issue_name]
  end

  def show
    projection = build_projection(params[:id], Event.in_order_of_creation)
    @reports = [projection]
  end

  private

  def build_projection(issue_name, events)
    IssueAuditProjection.new(
      app_name: apps.first,
      issue_name: issue_name,
      git_repository: git_repository,
    ).tap do |projection|
      projection.apply_all(events)
    end
  end

  def apps
    ['hello_world_rails']
  end

  def git_repository
    git_repository_loader.load(apps.first)
  end
end
