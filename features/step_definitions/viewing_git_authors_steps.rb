Given 'a repository called "$name"' do |name|
  dir = Dir.mktmpdir
  @repo = Rugged::Repository.init_at(dir)
  @repo.config['user.name'] = "Unconfigured"
  @repo.config['user.email'] = "unconfigured@example.com"

  RepositoryLocation.create(uri: "file://#{dir}", name: name)
end

Given 'a commit by "$name" is created' do |name|
  @commits ||= []
  oid = @repo.write("This is about #{name} at #{Time.now}", :blob)
  index = @repo.index

  index.read_tree(@repo.head.target.tree) unless @repo.empty?
  index.add(path: "README.md", oid: oid, mode: 0100644)

  options = {}
  options[:tree] = index.write_tree(@repo)

  options[:author] = { email: "#{name.parameterize}@github.com", name: name, time: Time.now }
  options[:commiter] = { email: "#{name.parameterize}@github.com", name: name, time: Time.now }
  options[:message] ||= "#{name} making a commit"
  options[:parents] = @repo.empty? ? [] : [@repo.head.target].compact
  options[:update_ref] = 'HEAD'

  @commits.push Rugged::Commit.create(@repo, options)
end

When 'I compare the beginning with the last commit for "$name"' do |name|
  release_audit_page.request(
    project_name: name,
    from: nil,
    to: @commits.last
  )
end

When 'I compare the second commit with the fourth commit for "$name"' do |name|
  release_audit_page.request(
    project_name: name,
    from: @commits[1],
    to: @commits[3]
  )
end

Then 'I should see the authors "$author1" and "$author2"' do |author1, author2|
  expect(release_audit_page.authors).to include(author1, author2)
end
