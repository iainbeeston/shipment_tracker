When 'I look up feature reviews for "$version" on "$app"' do |version, app|
  sha = scenario_context.resolve_version(version)
  feature_review_search_page.search_for(app: app, version: sha)
end

Then 'I should see the feature review for' do |links_table|
  links = links_table.hashes.map { |hash|
    Sections::FeatureReviewLinkSection.new('link' => feature_review_url(hash))
  }

  expect(feature_review_search_page.links).to match_array(links)
end

Then 'I select link to feature review "$link_number"' do |link_number|
  feature_review_search_page.click_nth_link(link_number)
end

def feature_review_url(hash)
  parameters = {
    'apps' => { hash['app_name'] => scenario_context.resolve_version(hash['version']) },
    'uat_url' => hash['uat'],
  }.to_query
  "http://www.example.com/feature_reviews?#{parameters}"
end

Then 'I should see a warning: "$warning"' do |warning|
  expect(error_message.text).to eq(warning)
end
