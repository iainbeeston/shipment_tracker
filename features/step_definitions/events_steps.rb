Given 'a failing CircleCi build for "$version"' do |version|
  payload = build(
    :circle_ci_event,
    success?: false,
    version: default_repo.commit_for_pretend_version(version),
  ).details
  post_json '/events/circleci', payload
end

Given 'a ticket "$key" with summary "$summary" is started' do |key, summary|
  @tickets ||= {}
  @tickets[key] = { key: key, summary: summary }

  event = build(:jira_event, :to_do, @tickets.fetch(key))
  post_json '/events/jira', event.details

  event = build(:jira_event, :in_progress, @tickets.fetch(key))
  post_json '/events/jira', event.details
end

Given 'CircleCi "$outcome" for commit "$version"' do |outcome, version|
  payload = build(
    :circle_ci_event,
    success?: outcome == 'passes',
    version: default_repo.commit_for_pretend_version(version),
  ).details
  post_json '/events/circleci', payload
end

Given 'ticket "$key" is approved by "$approver_email" at "$time"' do |jira_key, approver_email, time|
  event = build(:jira_event, :done, @tickets.fetch(jira_key).merge(user_email: approver_email, updated: time))
  post_json '/events/jira', event.details
end

Given 'commit "$version" is deployed by "$name" on server "$server"' do |version, name, server|
  post_json '/deploys', build(
    :deploy_event,
    server: server,
    app_name: default_application,
    version: default_repo.commit_for_pretend_version(version),
    deployed_by: name,
  ).details
end

def post_json(url, payload)
  post url, payload.to_json, 'CONTENT_TYPE' => 'application/json'
end
