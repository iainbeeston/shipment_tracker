require 'support/git_repository_factory'

def setup_application(name)
  dir = Dir.mktmpdir

  @application = name

  @repos ||= {}
  @repos[name] = Support::GitRepositoryFactory.new(dir)

  RepositoryLocation.create(uri: "file://#{dir}", name: name)
end

def repo_for(application)
  @repos[application]
end

def commit_from_pretend(pretend_commit)
  value = @repos.values.map { |r| r.commit_for_pretend_version(pretend_commit) }.compact.first
  fail "Could not find '#{pretend_commit}'" unless value
  value
end

def default_repo
  @repos[default_application]
end

def default_application
  @application
end

Given 'an application called "$name"' do |name|
  setup_application(name)
end

Given 'an application with some commits' do
  setup_application('my_app')
  default_repo.create_commit(author_name: 'Adam', pretend_version: '#1')
  default_repo.create_commit(author_name: 'Eve', pretend_version: '#2')
end

Given 'a commit "$version" by "$name" is created' do |version, name|
  default_repo.create_commit(author_name: name, pretend_version: version)
end

Given('a commit "$v" by "$a" is created for ticket "$k" for "$app"') do |version, author, jira_key, app|
  repo_for(app).create_commit(
    author_name: author,
    pretend_version: version,
    message: "#{jira_key} work",
  )
end

Given(/^a commit "(.*?)" by "(.*?)" is created for ticket "([^\"]+)"$/) do |version, author, jira_key|
  default_repo.create_commit(
    author_name: author,
    pretend_version: version,
    message: "#{jira_key} work",
  )
end

Given 'a commit "$version" by "$name" is created with message "$message"' do |version, name, message|
  default_repo.create_commit(
    author_name: name,
    pretend_version: version,
    message: message,
  )
end
