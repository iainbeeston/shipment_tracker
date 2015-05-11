class CircleCiEvent < Event
  def source
    "CircleCi"
  end

  def status
    details.fetch('payload', {}).fetch('outcome', 'unknown')
  end

  def version
    details.fetch('payload', {}).fetch('vcs_revision', 'unknown')
  end
end
