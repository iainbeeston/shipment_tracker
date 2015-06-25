class FeatureReviewProjection
  def initialize(builds_projection:, deploys_projection:, manual_tests_projection:, tickets_projection:)
    @builds_projection = builds_projection
    @deploys_projection = deploys_projection
    @manual_tests_projection = manual_tests_projection
    @tickets_projection = tickets_projection

    @events_queue = []
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

  def locked?
    @tickets_projection.approved?
  end

  def apply(event)
    if locked? && !unlocking_event?(event)
      queue_event(event)
    else
      apply_queued_events_to_projections
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

  def unlocking_event?(event)
    event.is_a?(JiraEvent) && event.unapproval?
  end

  def queue_event(event)
    @events_queue << event
  end

  def apply_queued_events_to_projections
    @events_queue.each do |queued_event|
      apply_to_projections(queued_event)
    end
    @events_queue = []
  end
end
