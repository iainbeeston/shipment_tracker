require 'event'

class CircleCiEvent < Event
  def source
    'CircleCi'
  end

  def success
    status = details
             .fetch('payload', {})
             .fetch('outcome', nil)

    status == 'success'
  end

  def version
    details.fetch('payload', {}).fetch('vcs_revision', 'unknown')
  end
end
