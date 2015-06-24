When 'I look up feature reviews for "$version"' do |version|
  sha = scenario_context.resolve_version(version)
  feature_review_search_page.visit(sha)
end

Then 'I should see the feature review for' do |links_table|
  links = links_table.hashes.map { |hash|
    Sections::FeatureReviewLinkSection.new('link' => feature_review_path(hash))
  }

  expect(feature_review_search_page.links).to match_array(links)
end

Then 'I select link to feature review "$link_number"' do |link_number|
  feature_review_search_page.click_nth_link(link_number)
end

def feature_review_path(hash)
  parameters = {
    'apps' => { hash['app_name'] => scenario_context.resolve_version(hash['version']) },
    'uat_url' => hash['uat'],
  }.to_query
  "/feature_reviews?#{parameters}"
end
