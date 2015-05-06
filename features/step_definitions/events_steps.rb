require 'rack/test'

World(Rack::Test::Methods)

Given '"$app_name" was deployed' do |app_name, table|
  table.hashes.each do |hash|
    post_json '/deploys',
      server: hash['server'],
      app_name: app_name,
      version: @repo.commits.last.version,
      deployed_at: Time.parse(hash['deployed_at']).to_i,
      deployed_by: hash['deployed_by']
  end
end

Given 'a failing CircleCi build for "$version"' do |version|
  post_json '/events/circleci',
    'payload' => {
      'status' => 'failing',
      'vcs_revision' => @repo.commit_for_pretend_version(version),
    }
end

Given 'a passing CircleCi build for "$version"' do |version|
  post_json '/events/circleci',
    'payload' => {
      'status' => 'success',
      'vcs_revision' => @repo.commit_for_pretend_version(version),
    }
end

def post_json(url, payload)
  post url, payload.to_json, "CONTENT_TYPE" => "application/json"
end
