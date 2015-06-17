Given 'I am logged in as "$email"' do |email|
  page.set_rack_session current_user: { first_name: email.split('@').first, email: email }
end
