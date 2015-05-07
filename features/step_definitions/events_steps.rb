require 'rack/test'

World(Rack::Test::Methods)

Given '"$app_name" was deployed' do |app_name, table|
  table.hashes.each do |hash|
    post_json '/deploys',
      server: hash['server'],
      app_name: app_name,
      version: @repo.commits.last.version,
      deployed_at: Time.parse(hash['deployed_at']).to_i,
      deployed_by: hash['deployed_by']
  end
end

Given 'a failing CircleCi build for "$version"' do |version|
  payload = FactoryGirl.build(
    :circle_ci_event,
    success?: false,
    version: @repo.commit_for_pretend_version(version)
  ).details
  post_json '/events/circleci', payload
end

Given 'a passing CircleCi build for "$version"' do |version|
  payload = FactoryGirl.build(
    :circle_ci_event,
    success?: true,
    version: @repo.commit_for_pretend_version(version)
  ).details
  post_json '/events/circleci', payload
end

Given 'a passing Jenkins build for "$version"' do |version|
  payload = FactoryGirl.build(
    :jenkins_event,
    success?: true,
    version: @repo.commit_for_pretend_version(version)
  ).details
  post_json '/events/jenkins', payload
end

Given 'these tickets' do |table|
  table.hashes.each do |hash|
    end_status = hash.fetch('status').parameterize.underscore.to_sym
    events = jira_events(end_status, hash.slice('key', 'summary'))
    events.each do |event|
      post_json '/events/jira', event.details
    end
  end
end

def post_json(url, payload)
  post url, payload.to_json, "CONTENT_TYPE" => "application/json"
end
