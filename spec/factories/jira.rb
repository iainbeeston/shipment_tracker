FactoryGirl.define do
  factory :jira do
    skip_create

    transient do
      sequence(:id) { |n| "JIRA-#{n}" }
      sequence(:title) { |n| "Implement Autoloan #{n}" }
    end

    details {
      {
        'issue' => {
          'key' => id,
          'fields' => {
            'summary' => title,
          }
        }
      }
    }

    initialize_with { new(attributes) }
  end
end
