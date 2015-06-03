require 'forwardable'

class FeatureReviewPresenter
  extend Forwardable

  def_delegators :@projection, :tickets, :builds, :deploys, :qa_submission

  def initialize(projection)
    @projection = projection
  end

  def build_status
    builds = @projection.builds.values.flatten

    return nil if builds.empty?

    if builds.all? { |b| b.status == 'success' }
      'success'
    else
      'failed'
    end
  end

  def deploy_status
    relevant_deploys = @projection.deploys.reject { |d| d.correct == :ignore }

    return nil if relevant_deploys.empty?

    if relevant_deploys.all? { |d| d.correct == :yes }
      'success'
    else
      'failed'
    end
  end

  def qa_status
    return nil unless @projection.qa_submission

    if @projection.qa_submission.status == 'accepted'
      'success'
    else
      'failed'
    end
  end

  def summary_status
    if statuses.all? { |status| status == 'success' }
      'success'
    elsif statuses.any? { |status| status == 'failed' }
      'failed'
    end
  end

  private

  def statuses
    [deploy_status, qa_status, build_status]
  end
end
