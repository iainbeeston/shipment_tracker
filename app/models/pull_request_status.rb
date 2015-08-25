require 'octokit'
require 'active_support/json'
require 'feature_review_with_statuses'
require 'repositories/feature_review_repository'

class PullRequestStatus
  def initialize(owner:,
                 repo_name:,
                 sha:,
                 token: Rails.application.config.github_access_token,
                 routes: Rails.application.routes.url_helpers)
    @owner = owner
    @repo_name = repo_name
    @sha = sha
    @token = token
    @routes = routes
  end

  def update
    feature_reviews = feature_reviews([sha])
    status, description = *status_for(feature_reviews).values_at(:status, :description)
    url = url_for(feature_reviews)
    publish_status(status, description, url)
  end

  def feature_reviews(commits)
    Repositories::FeatureReviewRepository.new.feature_reviews_for(commits).map do |feature_review|
      FeatureReviewWithStatuses.new(feature_review)
    end
  end

  def publish_status(status, description, url)
    client.create_status("#{owner}/#{repo_name}", sha, status,
      context: 'shipment_tracker',
      target_url: url,
      description: description)
  end

  def url_for(feature_reviews)
    if feature_reviews.empty?
      routes.new_feature_reviews_url
    elsif feature_reviews.length == 1
      feature_reviews.first.url
    else
      routes.search_feature_reviews_url(application: repo_name, versions: sha)
    end
  end

  def status_for(feature_reviews)
    if feature_reviews.empty?
      not_reviewed_status
    elsif feature_reviews.any?(&:approved?)
      approved_status
    else
      unapproved_status
    end
  end

  private

  attr_reader :owner, :repo_name, :sha, :token, :routes

  def client
    @client ||= Octokit::Client.new(access_token: token)
  end

  def not_reviewed_status
    {
      status: 'pending',
      description: 'There are no feature reviews for this commit, ' \
                   'please create one in Shipment Tracker',
    }
  end

  def approved_status
    {
      status: 'success',
      description: 'There are approved feature reviews for this commit',
    }
  end

  def unapproved_status
    {
      status: 'failure',
      description: 'No feature reviews for this commit have been approved',
    }
  end
end
