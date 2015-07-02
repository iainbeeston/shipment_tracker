class EventFactory
  def initialize(internal_types:, external_types:)
    @internal_types = internal_types
    @external_types = external_types
  end

  def create(endpoint, payload, current_user)
    details = decorate_with_email(endpoint, payload, current_user)
    event_type(endpoint).create(details: details)
  end

  private

  def decorate_with_email(endpoint, payload, current_user)
    return payload unless internal_event_type?(endpoint) && current_user.present?
    payload.merge('email' => current_user.email)
  end

  def event_type(endpoint)
    event_types.fetch(endpoint) { |type| fail "Unrecognized event type '#{type}'" }
  end

  def event_types
    @internal_types.merge(@external_types)
  end

  def internal_event_type?(type)
    @internal_types.key?(type)
  end
end
