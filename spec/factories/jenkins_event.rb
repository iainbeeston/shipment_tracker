# rubocop:disable Style/BlockDelimiters
FactoryGirl.define do
  factory :jenkins_event do
    transient do
      success? true
      sequence(:version)
    end

    details {
      {
        'build' => {
          'scm' => {
            'commit' => version,
          },
          'status' => success? ? 'SUCCESS' : 'FAILURE',
        },
      }
    }

    initialize_with { new(attributes) }
  end
end
# rubocop:enable Style/BlockDelimiters
