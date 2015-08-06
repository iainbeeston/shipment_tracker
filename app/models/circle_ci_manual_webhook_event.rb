require 'event'

class CircleCiManualWebhookEvent < CircleCiEvent
  def success
    all_steps_but_last = details.fetch('steps', [])[0..-2]
    actions = all_steps_but_last.flat_map { |s| s.fetch('actions', []) }
    actions.present? && actions.all? { |a| a['status'] == 'success' }
  end

  def version
    details.fetch('vcs_revision', 'unknown')
  end
end
