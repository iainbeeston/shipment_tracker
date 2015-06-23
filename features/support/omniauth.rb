Before('@fake_authentication') do
  OmniAuth.config.test_mode = true
end

After('@fake_authentication') do
  OmniAuth.config.test_mode = false
end
