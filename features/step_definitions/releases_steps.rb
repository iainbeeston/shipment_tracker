When 'I view the releases for "$app"' do |app|
  releases_page.visit(app)
end

Then 'I should see the releases' do |releases_table|
  expected_releases = releases_table.hashes.map { |release|
    Sections::ReleaseSection.new(
      date: release.fetch('date'),
      id: scenario_context.resolve_version(release.fetch('id')),
      message: release.fetch('message'),
      feature_review_status: release.fetch('issue audit'),
      feature_review_path: (scenario_context.review_path if release.fetch('issue audit').present?),
    )
  }

  expect(releases_page.releases).to eq(expected_releases)
end
