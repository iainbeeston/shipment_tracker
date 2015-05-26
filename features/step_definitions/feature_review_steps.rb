Given 'I prepare a feature review for:' do |table|
  prepare_feature_review_page.visit

  table.hashes.each do |row|
    prepare_feature_review_page.add(
      field_name: row.fetch('field name'),
      content: row.fetch('content'),
    )
  end

  prepare_feature_review_page.submit
end

Then 'I should see the feature review page with the applications:' do |table|
  expected_app_info = table.hashes.map { |hash|
    Sections::AppInfoSection.new(hash)
  }

  expect(feature_review_page.app_info).to match_array(expected_app_info)
end

Given 'a developer prepares a review for UAT "$uat_url" with apps' do |uat_url, apps_table|
  scenario_context.prepare_review(apps_table.hashes, uat_url)
end

When 'I visit the feature review' do
  visit scenario_context.review_url
end

Then 'I should see the builds for "$app"' do |app_name, builds_table|
  expected_builds = builds_table.hashes.map { |build|
    Sections::BuildSection.new(
      source: build.fetch('source'),
      status: build.fetch('status'),
    )
  }

  expect(feature_review_page.builds(for_app: app_name)).to match_array(expected_builds)
end

Then 'I can see the UAT environment "$uat"' do |uat|
  expect(feature_review_page.uat_url).to eq(uat)
end

Then 'I should see the deploys' do |deploys_table|
  expected_deploys = deploys_table.hashes.map { |deploy|
    Sections::FeatureReviewDeploySection.new(
      app_name: deploy.fetch('app_name'),
      version: scenario_context.resolve_version(deploy.fetch('version')),
      correct: deploy.fetch('correct'),
    )
  }

  expect(feature_review_page.deploys).to match_array(expected_deploys)
end

Then 'I should only see the ticket' do |ticket_table|
  expected_tickets = ticket_table.hashes.map { |ticket|
    Sections::TicketSection.new(
      key: ticket.fetch('key'),
      summary: ticket.fetch('summary'),
      description: ticket.fetch('description'),
      status: ticket.fetch('status'),
    )
  }

  expect(feature_review_page.tickets).to match_array(expected_tickets)
end

When 'I "$status" the feature as "$name"' do |status, name|
  feature_review_page.create_qa_submission(status: status, name: name)
end

When 'I should see the feature "$status" by "$name"' do |status, name|
  expect(feature_review_page.qa_submission).to include(status)
  expect(feature_review_page.qa_submission).to include(name)
end
