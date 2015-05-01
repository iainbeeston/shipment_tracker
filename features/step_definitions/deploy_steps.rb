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

def post_json(url, payload)
  post url, payload.to_json, "CONTENT_TYPE" => "application/json"
end
