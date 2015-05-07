FactoryGirl.define do
  factory :jira_event do
    skip_create

    transient do
      sequence(:key) { |n| "JIRA-#{n}" }
      sequence(:summary) { |n| "Implement Autoloan #{n}" }
    end

    details {
      {
        'issue' => {
          'key' => key,
          'fields' => {
            'summary' => summary,
          }
        }
      }
    }

    initialize_with { new(attributes) }
  end
end
