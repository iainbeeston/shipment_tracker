FactoryGirl.define do
  factory :jira_event do
    skip_create

    transient do
      sequence(:key) { |n| "JIRA-#{n}" }
      sequence(:summary) { |n| "Implement Autoloan #{n}" }

      display_name 'joe'
      user_email 'joe.bloggs@example.com'
      status 'To Do'

      change_log_items []
    end

    details {
      {
        'user' => {
          'displayName' => display_name,
          'emailAddress' => user_email
        },
        'issue' => {
          'key' => key,
          'fields' => {
            'summary' => summary,
            'status' => { 'name' => status }
          },
        },
        'changelog' => {
          'items'=> change_log_items
        },
      }
    }

    initialize_with { new(attributes) }

    trait :to_do do
      status 'To Do'
    end

    trait :in_progress do
      change_log_items [{'field'=>'status', 'toString'=>'In Progress'}]
      status 'In Progress'
    end

    trait :ready_for_review do
      change_log_items [{'field'=>'status', 'toString'=>'Ready For Review'}]
      status 'Ready For Review'
    end

    trait :done do
      change_log_items [{'field'=>'status', 'toString'=>'Done'}]
      status 'Done'
    end
  end
end
