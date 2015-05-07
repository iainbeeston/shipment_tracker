FactoryGirl.define do
  factory :jira_event do
    skip_create

    transient do
      sequence(:key) { |n| "JIRA-#{n}" }
      sequence(:summary) { |n| "Implement Autoloan #{n}" }
      status 'To Do'
    end

    details {
      {
        'issue' => {
          'key' => key,
          'fields' => {
            'summary' => summary,
            'status' => { 'name' => status }
          },
        }
      }
    }

    initialize_with { new(attributes) }

    trait :to_do do
      status 'To Do'
    end

    trait :in_progress do
      status 'In Progress'
    end

    trait :ready_for_review do
      status 'Ready For Review'
    end

    trait :done do
      status 'Done'
    end
  end
end
