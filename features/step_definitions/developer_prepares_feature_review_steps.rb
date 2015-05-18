Given 'I prepare a feature review for:' do |table|
  prepare_feature_review_page.visit

  table.hashes.each do |row|
    prepare_feature_review_page.add(
      app_name: row.fetch('app_name'),
      version: row.fetch('version'),
    )
  end

  prepare_feature_review_page.submit
end

Then 'I should see the feature review page with:' do |table|
  expected_app_info = table.hashes.map { |hash|
    Sections::AppInfoSection.new(hash)
  }

  expect(feature_review_page.app_info).to match_array(expected_app_info)
end
