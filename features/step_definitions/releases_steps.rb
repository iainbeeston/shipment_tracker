When 'I view the releases for "$app"' do |app|
  releases_page.visit(app)
end

Then 'I should see the releases' do |releases_table|
  expected_releases = releases_table.hashes.map { |release|
    Sections::ReleaseSection.new(
      message: release.fetch('message'),
    )
  }

  expect(releases_page.releases).to eq(expected_releases)
end
