# rubocop:disable Style/BlockDelimiters
FactoryGirl.define do
  factory :circle_ci_event do
    transient do
      success? true
      sequence(:version)
    end

    details {
      {
        'payload' => {
          'outcome' => success? ? 'success' : 'failed',
          'vcs_revision' => version,
        },
      }
    }

    initialize_with { new(attributes) }
  end
end
# rubocop:enable Style/BlockDelimiters
