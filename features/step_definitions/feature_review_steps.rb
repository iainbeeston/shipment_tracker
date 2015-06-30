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
    Sections::AppInfoSection.new(
      app_name: hash.fetch('app_name'),
      version: scenario_context.resolve_version(hash.fetch('version')),
    )
  }

  expect(feature_review_page.app_info).to match_array(expected_app_info)
end

Given 'a developer prepares a review for UAT "$uat_url" with apps' do |uat_url, apps_table|
  scenario_context.prepare_review(apps_table.hashes, uat_url)
end

When 'I visit the feature review' do
  visit scenario_context.review_url
end

Then 'I should see the builds with heading "$status" and content' do |status, builds_table|
  expected_builds = builds_table.hashes.map { |build|
    Sections::BuildSection.new(
      app: build.fetch('app'),
      source: build.fetch('source'),
      status: build.fetch('status'),
    )
  }

  expect(feature_review_page.panel_heading_status('builds')).to eq(status)
  expect(feature_review_page.builds).to match_array(expected_builds)
end

Then 'I can see the UAT environment "$uat"' do |uat|
  expect(feature_review_page.uat_url).to eq(uat)
end

Then 'I should see the deploys to UAT with heading "$status" and content' do |status, deploys_table|
  expected_deploys = deploys_table.hashes.map { |deploy|
    Sections::FeatureReviewDeploySection.new(
      app_name: deploy.fetch('app_name'),
      version: scenario_context.resolve_version(deploy.fetch('version')),
      correct: deploy.fetch('correct'),
    )
  }

  expect(feature_review_page.panel_heading_status('deploys')).to eq(status)
  expect(feature_review_page.deploys).to match_array(expected_deploys)
end

Then 'I should only see the ticket' do |ticket_table|
  expected_tickets = ticket_table.hashes

  expect(feature_review_page.tickets).to match_array(expected_tickets)
end

Then(/^(I should see )?a summary with heading "([^\"]*)" and content$/) do |_, status, summary_table|
  expected_summary = summary_table.hashes.map { |summary_item|
    Sections::SummarySection.new(
      status: summary_item.fetch('status'),
      title: summary_item.fetch('title'),
    )
  }

  expect(feature_review_page.panel_heading_status('summary')).to eq(status)
  expect(feature_review_page.summary_contents).to match_array(expected_summary)
end

When 'tester "$name" "$action" the feature' do |name, action|
  feature_review_page.create_qa_submission(
    name: name,
    status: action.chomp('s'),
  )
end

Then 'I should see that the feature review is locked' do
  expect(feature_review_page).to be_locked
end

Then 'I should see that the feature review is not locked' do
  expect(feature_review_page).to_not be_locked
end

Then(/^I should see the QA acceptance with heading "([^\"]*)"$/) do |status|
  expect(feature_review_page.panel_heading_status('qa-submission')).to eq(status)
end

Then 'I should see the QA acceptance with heading "$status" and name "$name"' do |status, name|
  expected_qa_submission = Sections::QaSubmissionSection.new(name: name)

  expect(feature_review_page.panel_heading_status('qa-submission')).to eq(status)
  expect(feature_review_page.qa_submission).to eq(expected_qa_submission)
end
