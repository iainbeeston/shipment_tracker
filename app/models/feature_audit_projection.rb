require 'git_repository'

class FeatureAuditProjection
  attr_reader :authors, :deploys

  def initialize(app_name:, from:, to:)
    @app_name = app_name
    @from = from
    @to = to
  end

  def authors
    commits.map(&:author_name).uniq
  end

  def deploys
    deploys_for_app.map(&:details).map do |deploy|
      {
        server: deploy['server'],
        version: deploy['version'],
        deployed_at: Time.at(deploy['deployed_at']).strftime("%F %H:%M"),
        deployed_by: deploy['deployed_by']
      }
    end
  end

  private

  attr_reader :app_name, :from, :to

  def commits
    @commits ||= GitRepository.commits_for(
      repository_name: app_name,
      from: from,
      to: to
    )
  end

  def shas
    commits.map(&:id)
  end

  def deploys_for_app
    Deploy.deploys_for_app(app_name).select { |deploy|
      shas.include?(deploy.details['version'])
    }
  end
end
