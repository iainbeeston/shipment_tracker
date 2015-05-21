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

When 'I visit a feature review for UAT "$uat" and apps:' do |uat_url, apps_table|
  apps_hash = apps_table.hashes.reduce({}) { |apps, app|
    apps.merge(app[:app_name] => scenario_context.resolve_version(app[:version]))
  }
  visit "/feature_reviews?#{{ apps: apps_hash, uat_url: uat_url }.to_query}"
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
