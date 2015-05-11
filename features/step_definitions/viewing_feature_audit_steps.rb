When 'I compare commit "$ver1" with commit "$ver2" for "$application"' do |ver1, ver2, application|
  git_commit_1 = ver1.start_with?("#") ? @repo.commit_for_pretend_version(ver1) : ver1
  git_commit_2 = ver2.start_with?("#") ? @repo.commit_for_pretend_version(ver2) : ver2

  feature_audit_page.request(
    project_name: application,
    from: git_commit_1,
    to: git_commit_2
  )
end

Then 'I should only see the authors:' do |authors_table|
  authors = authors_table.hashes.map { |row| row['author'] }
  expect(feature_audit_page.authors).to match_array(authors)
end

Then 'I should only see the authors "$authors"' do |authors_list|
  authors = argument_array(authors_list)
  expect(error_message).to_not be_present, "Did not expect any errors, but got: #{error_message.text}"
  expect(feature_audit_page.authors).to match_array(authors)
end

Then 'the deploys' do |table|
  expected_deploys = table.hashes.map do |deploy|
    Sections::DeploySection.new(
      server: deploy.fetch("server"),
      deployed_by: deploy.fetch("deployed_by"),
      version: @repo.commit_for_pretend_version(deploy.fetch("commit"))
    )
  end

  expect(feature_audit_page.deploys).to match_array(expected_deploys)
end

Then 'the builds' do |table|
  expected_builds = table.hashes.map do |build|
    Sections::BuildSection.new(
      source: build.fetch("source"),
      status: build.fetch("status"),
      version: @repo.commit_for_pretend_version(build.fetch("commit")),
    )
  end

  expect(feature_audit_page.builds).to match_array(expected_builds)
end

Then 'the tickets' do |table|
  expected_tickets = table.hashes.map do |ticket|
    Sections::TicketSection.new(
      key: ticket.fetch("key"),
      summary: ticket.fetch("summary"),
      status: ticket.fetch("status"),
      approver_email: ticket.fetch("approver email")
    )
  end

  expect(feature_audit_page.tickets).to match_array(expected_tickets)
end
