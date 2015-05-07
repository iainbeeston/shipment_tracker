FactoryGirl.define do
  factory :jenkins do
    skip_create

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
          'status' => success? ? 'SUCCESS' : 'FAILURE'
        }
      }
    }

    initialize_with { new(attributes) }
  end
end
