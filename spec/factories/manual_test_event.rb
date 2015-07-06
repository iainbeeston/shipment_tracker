# rubocop:disable Style/BlockDelimiters
FactoryGirl.define do
  factory :manual_test_event do
    transient do
      success? true
      email 'alice@example.com'
      comment 'LGTM'
      apps [{ name: 'frontend', version: 'abc' }]
    end

    details {
      {
        status: success? ? 'success' : 'failed',
        email: email,
        comment: comment,
        apps: apps,
      }
    }

    initialize_with { new(attributes) }
  end
end
# rubocop:enable Style/BlockDelimiters
