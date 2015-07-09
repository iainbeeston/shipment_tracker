class EventTypeRepository
  def initialize(event_types)
    @event_types = event_types
  end

  def self.build
    EventTypeRepository.new(
      [
        EventType.new(name: 'CircleCI', endpoint: 'circleci', event_class: CircleCiEvent),
        EventType.new(
          name: 'CircleCI (manual)',
          endpoint: 'circleci-manual',
          event_class: CircleCiManualWebhookEvent,
        ),
        EventType.new(name: 'Deployment', endpoint: 'deploy', event_class: DeployEvent),
        EventType.new(name: 'Jenkins', endpoint: 'jenkins', event_class: JenkinsEvent),
        EventType.new(name: 'JIRA', endpoint: 'jira', event_class: JiraEvent),
        EventType.new(name: 'UAT', endpoint: 'uat', event_class: UatEvent),
        EventType.new(
          name: 'Manual test',
          endpoint: 'manual_test',
          event_class: ManualTestEvent,
          internal: true,
        ),
      ],
    )
  end

  def find_by_endpoint(endpoint)
    @event_types.find { |t| t.endpoint == endpoint }.tap do |type|
      fail "Unrecognized event type '#{endpoint}'" if type.nil?
    end
  end

  def external_types
    @event_types.select(&:external?)
  end
end
