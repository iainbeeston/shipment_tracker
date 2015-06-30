require 'addressable/uri'

When 'I generate a token for "$source"' do |source|
  tokens_page.visit
  tokens_page.generate_token_for(source)
end

Then 'I should see a token for "$source" with a value' do |source|
  token = tokens_page.tokens.find { |t| t['Source'] == source }
  expect(token).to be

  token_url = Addressable::URI.parse(token['URL'])
  expect(token_url.scheme).to eq('http')
  expect(token_url.host).to eq('www.example.com')
  expect(token_url.path).to eq("/events/#{source}")
  expect(token_url.query_values['token'].length).to eq(24)
end
