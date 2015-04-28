require 'support/git_repository_factory'

Given 'a repository called "$name"' do |name|
  dir = Dir.mktmpdir
  @repo = Support::GitRepositoryFactory.new(dir)

  RepositoryLocation.create(uri: "file://#{dir}", name: name)
end

Given 'a commit by "$name" is created' do |name|
  @repo.create_commit(author_name: name)
end

When 'I compare the beginning with the last commit for "$name"' do |name|
  release_audit_page.request(
    project_name: name,
    from: nil,
    to: @repo.commits.last
  )
end

When 'I compare the second commit with the fourth commit for "$name"' do |name|
  release_audit_page.request(
    project_name: name,
    from: @repo.commits[1],
    to: @repo.commits[3]
  )
end

Then 'I should see the authors "$author1" and "$author2"' do |author1, author2|
  expect(release_audit_page.authors).to include(author1, author2)
end
