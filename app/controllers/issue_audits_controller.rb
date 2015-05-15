class IssueAuditsController < ApplicationController
  def index
    redirect_to issue_audit_path(params[:issue_name]) if params[:issue_name]
  end

  def show
    @reports = []
    apps.each do |app_name|
      projection = build_projection(params[:id], Event.in_order_of_creation, app_name)
      @reports << projection if projection.valid?
    end
  end

  private

  def build_projection(issue_name, events, app_name)
    IssueAuditProjection.new(
      app_name: app_name,
      issue_name: issue_name,
      git_repository: git_repository(app_name),
    ).tap do |projection|
      projection.apply_all(events)
    end
  end

  def apps
    RepositoryLocation.all.map(&:name)
  end

  def git_repository(app_name)
    git_repository_loader.load(app_name)
  end
end
