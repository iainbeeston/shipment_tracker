class CircleCiEvent < Event
  def source
    'CircleCi'
  end

  def success
    status = details
             .fetch('payload', {})
             .fetch('outcome', 'unknown').downcase

    {
      'success' => true,
      'failed' => false,
    }[status]
  end

  def version
    details.fetch('payload', {}).fetch('vcs_revision', 'unknown')
  end
end
