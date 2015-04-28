World(Rack::Test::Methods)

Given "$user has deployed an app" do |user|
  post_json '/deploys', { deployed_by: user }
end

When "I visit /deploys" do
  visit '/deploys'
end

Then "I should see a deploy by $user" do |user|
  expect(page).to have_content("Deployed by #{user}")
end

def post_json(url, payload)
  post url, payload.to_json, "CONTENT_TYPE" => "application/json"
end
