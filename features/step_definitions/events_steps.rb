Given 'a failing CircleCi build for "$version"' do |version|
  payload = build(
    :circle_ci_event,
    success?: false,
    version: scenario_context.resolve_version(version),
  ).details
  post_json '/events/circleci', payload
end

Given 'a ticket "$key" with summary "$summary" is started' do |key, summary|
  scenario_context.create_and_start_ticket(
    key:     key,
    summary: summary,
  )
end

Given 'CircleCi "$outcome" for commit "$version"' do |outcome, version|
  payload = build(
    :circle_ci_event,
    success?: outcome == 'passes',
    version: scenario_context.resolve_version(version),
  ).details

  post_json '/events/circleci', payload
end

Given 'ticket "$key" is approved by "$approver_email" at "$time"' do |jira_key, approver_email, time|
  scenario_context.approve_ticket(jira_key, approver_email: approver_email, time: time)
end

Given 'commit "$version" is deployed by "$name" on server "$server"' do |version, name, server|
  post_json '/deploys', build(
    :deploy_event,
    server: server,
    app_name: scenario_context.resolve_app(version),
    version: scenario_context.resolve_version(version),
    deployed_by: name,
  ).details
end

def post_json(url, payload)
  post url, payload.to_json, 'CONTENT_TYPE' => 'application/json'
end
