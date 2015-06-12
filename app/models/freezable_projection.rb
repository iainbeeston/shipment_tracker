require 'forwardable'

class FreezableProjection
  extend Forwardable

  def_delegators :@projection, :tickets, :builds, :deploys, :qa_submission

  def initialize(projection)
    @projection = projection

    @frozen = false
    @frozen_events = []
  end

  def apply_all(events)
    events.each do |event|
      apply(event)
    end
  end

  def apply(event)
    if @projection.approved? && !unfreezing?(event)
      @frozen_events << event
    else
      @projection.apply_all(@frozen_events)
      @frozen_events = []
      @projection.apply(event)
    end
  end

  private

  def unfreezing?(event)
    event.is_a?(JiraEvent) && event.unapproval?
  end
end
