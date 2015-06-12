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
    if frozen?
      if unfreezing?(event)
        unfreeze!
        apply_all(@frozen_events)
      else
        @frozen_events << event
        return
      end
    elsif freezing?(event)
      freeze!
    end

    @projection.apply(event)
  end

  private

  def freezing?(event)
    event.is_a?(JiraEvent) && event.status_changed_to?('Done')
  end

  def unfreezing?(event)
    event.is_a?(JiraEvent) && event.status_changed_from?('Done')
  end

  def freeze!
    @frozen = true
  end

  def unfreeze!
    @frozen = false
  end

  def frozen?
    @frozen
  end
end
