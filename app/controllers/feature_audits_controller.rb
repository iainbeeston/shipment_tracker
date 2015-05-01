require 'git_repository'

class FeatureAuditsController < ApplicationController
  def show
    commits = GitRepository.commits_for(
      repository_name: repository_name,
      from: clean_params[:from],
      to:   clean_params[:to]
    )

    @authors = commits.map { |commit| commit.fetch(:author_name) }
    @deploys = deploys(commits.map { |c| c[:id] })

  rescue GitRepository::CommitNotFound => e
    flash[:error] = "Commit '#{e.message}' could not be found in #{repository_name}"
  rescue GitRepository::CommitNotValid => e
    flash[:error] = "Commit '#{e.message}' is not valid"
  end

  private

  def repository_name
    clean_params[:id]
  end

  def clean_params
    @clean_params ||= params.select { |_k, v| v.present? }
  end

  def raw_deploys
    Deploy.deploys_for_app(params[:id])
  end

  def deploys(commit_ids = [])
    raw_deploys_for_versions = raw_deploys.select { |deploy| commit_ids.include?(deploy.details['version']) }

    raw_deploys_for_versions.map(&:details).map do |deploy|
      {
        server: deploy['server'],
        version: deploy['version'],
        deployed_at: Time.at(deploy['deployed_at']).strftime("%F %H:%M"),
        deployed_by: deploy['deployed_by']
      }
    end
  end
end
