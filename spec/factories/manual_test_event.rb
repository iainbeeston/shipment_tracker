# rubocop:disable Style/BlockDelimiters
FactoryGirl.define do
  factory :manual_test_event do
    transient do
      status 'success'
      email 'alice@example.com'
      comment 'LGTM'
      apps [{ name: 'frontend', version: 'abc' }]
    end

    details {
      {
        status: status,
        email: email,
        comment: comment,
        apps: apps,
      }
    }

    initialize_with { new(attributes) }
  end
end
# rubocop:enable Style/BlockDelimiters
