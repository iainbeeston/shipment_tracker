Then 'I should see the error "$error_message"' do |expected_error_message|
  expect(error_message).to be_present
  expect(error_message.text).to eq(expected_error_message)
end
