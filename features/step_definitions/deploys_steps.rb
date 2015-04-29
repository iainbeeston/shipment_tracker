World(Rack::Test::Methods)

Given 'a deploy' do |table|
  @hashes = table.hashes.each do |hash|
    post_json '/deploys',
              server: hash['server'],
              app_name: hash['app_name'],
              version: hash['software version'],
              deployed_at: Time.parse(hash['time']).to_i,
              deployed_by: hash['deployer']
  end
end

When 'I visit "$path"' do |path|
  visit path
end

Then 'I should see a deploy' do |table|
  @hashes = table.hashes

  @hashes.each do |hash|
    hash.each_value do |value|
      expect(all('.deploy').map(&:text)).to have_content(value)
    end
  end
end

def post_json(url, payload)
  post url, payload.to_json, "CONTENT_TYPE" => "application/json"
end
