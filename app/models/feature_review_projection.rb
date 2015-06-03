class FeatureReviewProjection
  attr_reader :builds, :qa_submission

  def initialize(apps:, uat_url:, projection_url:)
    @apps = apps
    @uat_url = uat_url
    @projection_url = projection_url

    @builds = {}
    @deploys = {}
    @tickets = {}
  end

  def apply_all(events)
    events.each do |event|
      apply(event)
    end
  end

  def deploys
    @deploys.values
  end

  def tickets
    @tickets.values
  end

  private

  attr_reader :projection_url

  def apply(event)
    case event
    when CircleCiEvent, JenkinsEvent
      apply_build_event(event)
    when DeployEvent
      apply_deploy_event(event)
    when JiraEvent
      apply_ticket_event(event)
    when ManualTestEvent
      apply_manual_test_event(event)
    end
  end

  def apply_build_event(build_event)
    app = versions[build_event.version]
    return unless app

    build = Build.new(
      source: build_event.source,
      status: build_event.status,
      version: build_event.version,
    )
    @builds[app] = @builds.fetch(app, []).push(build)
  end

  def apply_deploy_event(deploy_event)
    return unless deploy_event.server == @uat_url

    deploy = Deploy.new(
      app_name: deploy_event.app_name,
      server: deploy_event.server,
      version: deploy_event.version,
      deployed_by: deploy_event.deployed_by,
      correct: version_correctness_for_event(deploy_event),
    )
    @deploys[deploy_event.app_name] = deploy
  end

  def apply_ticket_event(ticket_event)
    return unless @tickets.key?(ticket_event.key) || matches_projection_url?(ticket_event.comment)

    ticket = Ticket.new(
      key: ticket_event.key,
      summary: ticket_event.summary,
      description: ticket_event.description,
      status: ticket_event.status,
    )
    @tickets[ticket_event.key] = ticket
  end

  def apply_manual_test_event(manual_test_event)
    return unless apps_hash(manual_test_event.apps) == @apps

    @qa_submission = QaSubmission.new(
      name: manual_test_event.user_name,
      status: manual_test_event.status == 'success' ? 'accepted' : 'rejected',
      created_at: manual_test_event.created_at,
    )
  end

  def versions
    @versions ||= @apps.invert
  end

  def version_correctness_for_event(event)
    return :ignore unless @apps.key?(event.app_name)
    event.version == @apps[event.app_name] ? :yes : :no
  end

  def matches_projection_url?(comment)
    URI.extract(comment).any? { |comment_url|
      extract_path(comment_url) == extract_path(projection_url)
    }
  end

  private

  def apps_hash(apps_list)
    apps_list.map { |app| app.values_at('name', 'version') }.to_h
  end

  def extract_path(url_string)
    Addressable::URI.parse(url_string).normalize.request_uri
  end
end
