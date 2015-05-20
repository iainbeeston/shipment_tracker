require 'support/git_test_repository'

Given 'an application called "$name"' do |name|
  scenario_context.setup_application(name)
end

Given 'an application with some commits' do
  scenario_context.setup_application('my_app')
  scenario_context.last_repository.create_commit(author_name: 'Adam', pretend_version: '#1')
  scenario_context.last_repository.create_commit(author_name: 'Eve', pretend_version: '#2')
end

Given 'a commit "$version" by "$name" is created' do |version, name|
  scenario_context.last_repository.create_commit(author_name: name, pretend_version: version)
end

Given 'a commit "$v" by "$a" is created for ticket "$k" for "$app"' do |version, author, jira_key, app|
  scenario_context.repository_for(app).create_commit(
    author_name: author,
    pretend_version: version,
    message: "#{jira_key} work",
  )
end

Given(/^a commit "(.*?)" by "(.*?)" is created for ticket "([^\"]+)"$/) do |version, author, jira_key|
  scenario_context.last_repository.create_commit(
    author_name: author,
    pretend_version: version,
    message: "#{jira_key} work",
  )
end

# rubocop:disable Metrics/LineLength
Given 'a commit "$v" by "$a" is created on branch "$b" for ticket "$t" for "$app"' do |version, author, branch, jira_key, app|
  repository = scenario_context.repository_for(app)
  repository.create_branch(branch)
  repository.checkout(branch)
  repository.create_commit(
    author_name: author,
    pretend_version: version,
    message: "#{jira_key} work",
  )
end
# rubocop:enable Metrics/LineLength

Given 'a commit "$version" by "$name" is created with message "$message"' do |version, name, message|
  scenario_context.last_repository.create_commit(
    author_name: name,
    pretend_version: version,
    message: message,
  )
end
