require 'git_repository'

class FeatureAuditProjection

  def self.for(repository_name:, from:, to:)
    commits = GitRepository.commits_for(
      repository_name: repository_name,
      from: from,
      to:   to
    )

    authors = commits.map { |commit| commit.fetch(:author_name) }
    deploys = deploys(repository_name, commits.map { |c| c[:id] })

    new(authors: authors, deploys: deploys)
  end

  attr_reader :authors, :deploys

  def initialize(authors:, deploys:)
    @authors = authors
    @deploys = deploys
  end

  def self.deploys(repository_name, commit_ids = [])
    raw_deploys_for_versions = Deploy.deploys_for_app(repository_name).select { |deploy| commit_ids.include?(deploy.details['version']) }

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
