Given 'a repository' do
  # Rugged::Repository.
end

Given 'a commit by "$name" is created' do |name|
  # pending # express the regexp above with the code you wish you had
end

When 'I compare the first commit with the last commit' do
  @first_commit = 1
  @last_commit = 2

  release_audit_page.request(
    from: @first_commit,
    to:   @last_commit
  )
end

Then 'I should see the authors "$author1" and "$author2"' do |author1, author2|
  expect(release_audit_page.authors).to include(author1, author2)
end
