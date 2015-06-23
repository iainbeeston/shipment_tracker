Given 'a ticket "$key" with summary "$summary" is started' do |key, summary|
  scenario_context.create_and_start_ticket(
    key: key,
    summary: summary,
  )
end

Given 'adds the link to a comment for ticket "$jira_key"' do |jira_key|
  scenario_context.link_ticket(jira_key)
end

Given 'ticket "$key" is approved by "$approver_email" at "$time"' do |jira_key, approver_email, time|
  scenario_context.approve_ticket(jira_key, approver_email: approver_email, time: time)
end

Given 'ticket "$key" is rejected' do |jira_key|
  scenario_context.reject_ticket(jira_key)
end

Given 'CircleCi "$outcome" for commit "$version"' do |outcome, version|
  payload = build(
    :circle_ci_event,
    success?: outcome == 'passes',
    version: scenario_context.resolve_version(version),
  ).details

  post_event 'circleci', payload
end

Given 'commit "$version" is deployed by "$name" on server "$server"' do |version, name, server|
  post_event 'deploy', build(
    :deploy_event,
    server: server,
    app_name: scenario_context.resolve_app(version),
    version: scenario_context.resolve_version(version),
    deployed_by: name,
  ).details
end

def post_event(type, payload)
  url = "/events/#{type}"
  post url, payload.to_json, 'CONTENT_TYPE' => 'application/json'
end
