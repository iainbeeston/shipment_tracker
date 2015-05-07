FactoryGirl.define do
  factory :circle_ci_event do
    skip_create

    transient do
      success? true
      sequence(:version)
    end

    details {
      {
        'payload' => {
          'outcome' => success? ? 'success' : 'failed',
          'vcs_revision' => version,
        }
      }
    }

    initialize_with { new(attributes) }
  end
end
