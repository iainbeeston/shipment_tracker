require 'events/jira_event'
require 'snapshots/feature_review'

module Repositories
  class FeatureReviewRepository
    def initialize(
          store = Snapshots::FeatureReview,
          git_repository_location: GitRepositoryLocation,
          pull_request_status: PullRequestStatus.new)
      @store = store
      @git_repository_location = git_repository_location
      @pull_request_status = pull_request_status
    end

    delegate :table_name, to: :store

    def feature_reviews_for(versions)
      store.where('versions && ARRAY[?]::varchar[]', versions).group_by(&:url).map { |_, snapshots|
        latest_snapshot = snapshots.max(&:event_created_at)
        Factories::FeatureReviewFactory.new.create(
          url: latest_snapshot.url,
          versions: latest_snapshot.versions,
        )
      }
    end

    def apply(event)
      return unless event.is_a?(Events::JiraEvent) && event.issue?

      Factories::FeatureReviewFactory.new.create_from_text(event.comment).each do |feature_review|
        store.create!(
          url: feature_review.url,
          versions: feature_review.versions,
          event_created_at: event.created_at,
        )

        feature_review.app_versions.each do |app_name, version|
          update_pull_requests(app_name, version)
        end
      end
    end

    def update_pull_requests(app_name, version)
      repository_location = git_repository_location.find_by_name(app_name)
      pull_request_status.update(
        repo_url: repository_location.uri,
        sha: version) if repository_location
    end

    private

    attr_reader :store, :git_repository_location, :pull_request_status
  end
end
