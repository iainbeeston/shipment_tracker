# rubocop:disable Style/BlockDelimiters
FactoryGirl.define do
  factory :jira_event do
    transient do
      sequence(:key) { |n| "JIRA-#{n}" }
      sequence(:summary) { |n| "Implement Autoloan #{n}" }

      display_name 'joe'
      user_email 'joe.bloggs@example.com'
      status 'To Do'
      updated "2015-05-07T15:24:34.957+0100"

      default_details do
        {
            'user' => {
                'displayName' => display_name,
                'emailAddress' => user_email,
            },
            'issue' => {
                'key' => key,
                'fields' => {
                    'summary' => summary,
                    'status' => { 'name' => status },
                    'updated' => updated,
                },
            },
        }
      end
      changelog_details({})
    end

    details { default_details.merge(changelog_details) }

    initialize_with { new(attributes) }

    trait :to_do do
      changelog_details(
        'changelog' => {
          'items' => [{ 'field' => 'status', 'toString' => 'To Do' }]
        }
      )
      status 'To Do'
    end

    trait :in_progress do
      changelog_details(
        'changelog' => {
          'items' => [{ 'field' => 'status', 'toString' => 'In Progress' }]
        }
      )
      status 'In Progress'
    end

    trait :ready_for_review do
      changelog_details(
        'changelog' => {
          'items' => [{ 'field' => 'status', 'toString' => 'Ready For Review' }]
        }
      )
      status 'Ready For Review'
    end

    trait :done do
      changelog_details(
        'changelog' => {
          'items' => [{ 'field' => 'status', 'toString' => 'Done' }]
        }
      )
      status 'Done'
    end
  end
end
# rubocop:enable Style/BlockDelimiters
