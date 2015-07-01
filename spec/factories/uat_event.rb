# rubocop:disable Style/BlockDelimiters
FactoryGirl.define do
  factory :uat_event do
    transient do
      success? true
      sequence(:test_suite_version)
      server 'uat.fundingcircle.com'
    end

    details {
      {
        'status' => success? ? 'success' : 'failed',
        'test_suite_version' => test_suite_version,
        'server' => server,
      }
    }

    initialize_with { new(attributes) }
  end
end
# rubocop:enable Style/BlockDelimiters
