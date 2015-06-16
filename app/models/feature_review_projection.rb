class FeatureReviewProjection
  def initialize(builds_projection:, deploys_projection:, manual_tests_projection:, tickets_projection:)
    @builds_projection = builds_projection
    @deploys_projection = deploys_projection
    @manual_tests_projection = manual_tests_projection
    @tickets_projection = tickets_projection

    @frozen_events = []
  end

  def self.build(apps:, uat_url:, projection_url:)
    new(
      builds_projection: BuildsProjection.new(apps: apps),
      deploys_projection: DeploysProjection.new(apps: apps, uat_url: uat_url),
      manual_tests_projection: ManualTestsProjection.new(apps: apps),
      tickets_projection: FeatureReviewTicketsProjection.new(projection_url: projection_url),
    )
  end

  def apply_all(events)
    events.each do |event|
      apply(event)
    end
  end

  def apply(event)
    if @tickets_projection.approved? && !unfreezing?(event)
      @frozen_events << event
    else
      @frozen_events.each do |frozen_event|
        apply_to_projections(frozen_event)
      end
      @frozen_events = []

      apply_to_projections(event)
    end
  end

  def deploys
    @deploys_projection.deploys
  end

  def tickets
    @tickets_projection.tickets
  end

  def builds
    @builds_projection.builds
  end

  def qa_submission
    @manual_tests_projection.qa_submission
  end

  private

  def apply_to_projections(event)
    @builds_projection.apply(event)
    @deploys_projection.apply(event)
    @tickets_projection.apply(event)
    @manual_tests_projection.apply(event)
  end

  def unfreezing?(event)
    event.is_a?(JiraEvent) && event.unapproval?
  end
end
