Given 'I am on the new repository location form' do
  repository_location_page.visit
end

When 'I enter "$name" and "$uri"' do |name, uri|
  repository_location_page.fill_in(name: name, uri: uri)
end

Then 'I should see the repository locations:' do |table|
  expected_repository_locations = table.hashes
  expect(repository_location_page.repository_locations).to eq(expected_repository_locations)
end
