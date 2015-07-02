require 'addressable/uri'

When 'I generate a token for "$source" with name "$name"' do |source, name|
  tokens_page.visit
  tokens_page.generate_token_for(source, name)
end

Then 'I should see a token for "$source" with name "$name"' do |source, name|
  token = tokens_page.tokens.find { |t| t['Source'] == source && t['Name'] == name }
  expect(token).to be_present

  token_url = Addressable::URI.parse(token['URL'])
  expect(token_url.scheme).to eq('http')
  expect(token_url.host).to eq('www.example.com')
  expect(token_url.path).to eq("/events/#{source}")
  expect(token_url.query_values['token'].length).to eq(24)
end

When 'I revoke it' do
  tokens_page.revoke_last_token
end

Then 'I should not see any tokens' do
  expect(tokens_page.tokens).to be_empty
end
