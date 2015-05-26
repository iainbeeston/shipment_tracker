# rubocop:disable Style/BlockDelimiters
FactoryGirl.define do
  factory :manual_test_event do
    transient do
      status 'success'
      name 'Alice'
      apps [{ name: 'frontend', version: 'abc' }]
    end

    details {
      {
        status: status,
        user: { name: name },
        testing_environment: { apps: apps },
      }
    }

    initialize_with { new(attributes) }
  end
end
# rubocop:enable Style/BlockDelimiters
