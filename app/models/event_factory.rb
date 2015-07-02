class EventFactory
  def initialize(internal_types:, external_types:)
    @internal_types = internal_types
    @external_types = external_types
  end

  def self.build
    EventFactory.new(
      external_types: {
        'circleci' => CircleCiEvent,
        'deploy'   => DeployEvent,
        'jenkins'  => JenkinsEvent,
        'jira'     => JiraEvent,
        'uat'      => UatEvent,
      },
      internal_types: {
        'manual_test' => ManualTestEvent,
      },
    )
  end

  def create(endpoint, payload, user_email)
    details = decorate_with_email(endpoint, payload, user_email)
    event_type(endpoint).create(details: details)
  end

  def supported_external_types
    @external_types.keys
  end

  private

  def decorate_with_email(endpoint, payload, email)
    return payload unless internal_event_type?(endpoint) && email.present?
    payload.merge('email' => email)
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
