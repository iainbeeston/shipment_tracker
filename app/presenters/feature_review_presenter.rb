require 'forwardable'

class FeatureReviewPresenter
  extend Forwardable

  def_delegators :@projection, :tickets, :builds, :deploys, :qa_submission, :uatest, :locked?, :uat_url

  def initialize(projection)
    @projection = projection
  end

  def build_status
    builds = @projection.builds.values

    return nil if builds.empty?

    if builds.all? { |b| b.status == 'success' }
      :success
    elsif builds.any? { |b| b.status == 'failed' }
      :failure
    end
  end

  def deploy_status
    return nil if @projection.deploys.empty?

    if @projection.deploys.all? { |d| d.correct == :yes }
      :success
    else
      :failure
    end
  end

  def qa_status
    return nil unless @projection.qa_submission

    if @projection.qa_submission.status == 'accepted'
      :success
    else
      :failure
    end
  end

  def uatest_status
    return nil unless @projection.uatest

    if @projection.uatest.status == 'success'
      :success
    else
      :failure
    end
  end

  def summary_status
    if statuses.all? { |status| status == :success }
      :success
    elsif statuses.any? { |status| status == :failure }
      :failure
    end
  end

  private

  def statuses
    [deploy_status, qa_status, build_status]
  end
end
