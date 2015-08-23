require 'feature_review_location'
require 'git_repository'
require 'events/jira_event'
require 'projections/releases_tickets_projection'
require 'release'
require 'ticket'

module Projections
  class ReleasesProjection
    attr_reader :pending_releases, :deployed_releases

    def initialize(per_page:, git_repository:, app_name:)
      @per_page = per_page
      @tickets_projection = Projections::ReleasesTicketsProjection.new
      @git_repository = git_repository
      @feature_reviews = {}
      @tickets_hash = {}
      @production_deploys = {}
      @pending_releases = []
      @deployed_releases = []
      @app_name = app_name
    end

    def apply_all(events)
      events.each do |event|
        apply(event)
      end
      categorize_releases
    end

    private

    attr_reader :tickets_projection, :app_name, :production_deploys

    def apply(event)
      case event
      when Events::DeployEvent
        return unless event.environment == 'production'
        return unless event.app_name == app_name
        @production_deploys[event.version] = event.created_at
      when Events::JiraEvent
        associate_releases_with_feature_review(event)
        tickets_projection.apply(event)
      end
    end

    def commits
      @commits ||= @git_repository.recent_commits(@per_page)
    end

    def categorize_releases
      associate_dependent_releases_with_feature_review

      deployed = false
      commits.each { |commit|
        deployed = true if production_deploys.key?(commit.id)
        if deployed
          @deployed_releases << create_release_from(commit)
        else
          @pending_releases << create_release_from(commit)
        end
      }
    end

    def create_release_from(commit)
      feature_review = feature_review_for_commit(commit.id)
      ticket = get_ticket(feature_review.fetch(:key))

      Release.new(
        version: commit.id,
        time: production_deploys[commit.id].try(:to_formatted_s, :long_ordinal),
        subject: commit.subject_line,
        feature_review_status: ticket.status,
        feature_review_path: feature_review.fetch(:path),
        approved: ticket.approved?,
      )
    end

    def get_ticket(key)
      tickets_projection.ticket_for(key) || Ticket.new(status: nil)
    end

    def associate_dependent_releases_with_feature_review
      feature_review_commit_versions.each do |sha|
        @git_repository.get_dependent_commits(sha).each do |dependent_commit|
          @feature_reviews[dependent_commit.id] = @feature_reviews[sha]
        end
      end
    end

    def feature_review_commit_versions
      @feature_reviews.keys
    end

    def feature_review_for_commit(commit_oid)
      @feature_reviews.fetch(commit_oid, key: nil, path: nil)
    end

    def associate_feature_review(commit_oid, feature_review)
      @feature_reviews[commit_oid] = feature_review
    end

    def associate_releases_with_feature_review(jira_event)
      FeatureReviewLocation.from_text(jira_event.comment).each do |location|
        commit_oids = extract_relevant_commit_from_location(location)
        commit_oids.each do |commit_oid|
          associate_feature_review(commit_oid, key: jira_event.key, path: location.path)
        end
      end
    end

    def extract_relevant_commit_from_location(feature_review_location)
      feature_review_location.versions.select { |commit_oid|
        commits.find { |c| c.id == commit_oid }
      }
    end
  end
end
