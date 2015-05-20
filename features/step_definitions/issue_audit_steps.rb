When 'I view activity for issue "$issue_name"' do |issue_name|
  issue_audit_page.request(issue_name: issue_name)
end

Then(/^I should only see the applications$/) do |application_table|
  expected_application_names = application_table.hashes.map { |application| application.fetch('application') }

  expect(issue_audit_page.application_names).to match_array(expected_application_names)
end

Then 'I should only see the ticket' do |ticket_table|
  expected_tickets = ticket_table.hashes.map { |ticket|
    Sections::TicketSection.new(
      key: ticket.fetch('key'),
      summary: ticket.fetch('summary'),
      status: ticket.fetch('status'),
      approver_email: ticket.fetch('approver email'),
      approved_at: ticket.fetch('approved at'),
    )
  }

  expect(issue_audit_page.tickets).to match_array(expected_tickets)
end

Then 'the authors for "$app_name"' do |app_name, authors_table|
  authors = authors_table.hashes.map { |row| row['author'] }
  expect(issue_audit_page.authors(for_app: app_name)).to match_array(authors)
end

Then 'the builds for "$app_name"' do |app_name, table|
  repo = scenario_context.repository_for(app_name)

  expected_builds = table.hashes.map { |build|
    commit = repo.commit_for_pretend_version!(build.fetch('commit'))
    Sections::BuildSection.new(
      source: build.fetch('source'),
      status: build.fetch('status'),
      version: commit,
    )
  }

  expect(issue_audit_page.builds(for_app: app_name)).to match_array(expected_builds)
end
