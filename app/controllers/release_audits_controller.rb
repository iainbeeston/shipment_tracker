require 'git_repository'

class ReleaseAuditsController < ApplicationController
  def show
    @authors = GitRepository.author_names_for(
      repository_name: repository_name,
      from: clean_params[:from],
      to:   clean_params[:to]
    )


    deploys = Deploy.deploys_for_app(params[:id])
    @deploys = map_deploy(deploys)

  rescue GitRepository::CommitNotFound => e
    flash[:error] = "Commit '#{e.message}' could not be found in #{repository_name}"
  rescue GitRepository::CommitNotValid => e
    flash[:error] = "Commit '#{e.message}' is not valid"
  rescue
    flash[:error] = "Please contact tech support"
  end

  private

  def repository_name
    clean_params[:id]
  end

  def clean_params
    @clean_params ||= params.select { |_k, v| v.present? }
  end

  def map_deploy(deploys)
    deploys.map(&:details).map do |deploy|
      {
        server: deploy['server'],
        version: deploy['version'],
        deployed_at: Time.at(deploy['deployed_at']).strftime("%F %H:%M"),
        deployed_by: deploy['deployed_by']
      }
    end
  end
end
