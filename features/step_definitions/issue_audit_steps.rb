When 'I view activity for issue "$issue_name"' do |issue_name|
  issue_audit_page.request(issue_name: issue_name)
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

And 'the authors' do |authors_table|
  authors = authors_table.hashes.map { |row| row['author'] }
  expect(issue_audit_page.authors).to match_array(authors)
end
