When 'I view the releases for "$app"' do |app|
  releases_page.visit(app)
end

Then 'I should see the "$deploy_status" releases' do |deploy_status, releases_table|
  expected_releases = releases_table.hashes.map { |release_line|
    release = {
      'version' => scenario_context.resolve_version(release_line.fetch('version')),
      'subject' => release_line.fetch('subject'),
      'feature_review_status' => release_line.fetch('issue audit'),
      'feature_review_path' => (scenario_context.review_path if release_line.fetch('issue audit').present?),
      'approved' => release_line.fetch('approved') == 'yes',
    }

    if deploy_status == 'deployed'
      time = release_line.fetch('last deployed at')
      if time.empty?
        release['time'] = nil
      else
        release['time'] = Time.parse(time)
      end
    end

    release
  }

  actual_releases = releases_page.public_send("#{deploy_status}_releases".to_sym)
  expect(actual_releases).to eq(expected_releases)
end
