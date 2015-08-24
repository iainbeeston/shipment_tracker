require 'repositories/build_repository'
require 'repositories/deploy_repository'
require 'repositories/manual_test_repository'
require 'repositories/ticket_repository'
require 'repositories/uatest_repository'

class FeatureReviewQuery
  attr_reader :app_versions, :time, :uat_url

  def initialize(feature_review, at:)
    @app_versions = feature_review.app_versions
    @versions = feature_review.versions
    @uat_host = feature_review.uat_host
    @uat_url = feature_review.uat_url
    @url = feature_review.url
    @build_repository = Repositories::BuildRepository.new
    @deploy_repository = Repositories::DeployRepository.new
    @manual_test_repository = Repositories::ManualTestRepository.new
    @ticket_repository = Repositories::TicketRepository.new
    @uatest_repository = Repositories::UatestRepository.new
    @time = at
  end

  def builds
    build_repository.builds_for(apps: app_versions, at: time)
  end

  def deploys
    deploy_repository.deploys_for(apps: app_versions, server: uat_host, at: time)
  end

  def qa_submission
    manual_test_repository.qa_submission_for(versions: versions, at: time)
  end

  def tickets
    ticket_repository.tickets_for(projection_url: url, at: time)
  end

  def uatest
    uatest_repository.uatest_for(versions: versions, server: uat_host, at: time)
  end

  private

  attr_reader :build_repository, :deploy_repository, :manual_test_repository, :ticket_repository,
    :uatest_repository
  attr_reader :feature_review, :versions, :url, :uat_host
end
