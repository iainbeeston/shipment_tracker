# rubocop:disable Style/BlockDelimiters
FactoryGirl.define do
  factory :jira_event do
    transient do
      sequence(:issue_id)
      sequence(:key) { |n| "JIRA-#{n}" }

      summary ''
      description ''
      display_name 'joe'
      user_email 'joe.bloggs@example.com'
      status 'To Do'
      updated '2015-05-07T15:24:34.957+0100'
      comment_body nil

      changelog_details({})

      default_details do
        {
          'user' => {
            'displayName' => display_name,
            'emailAddress' => user_email,
          },
          'issue' => {
            'id' => issue_id,
            'key' => key,
            'fields' => {
              'summary' => summary,
              'description' => description,
              'status' => { 'name' => status },
              'updated' => updated,
            },
          },
        }
      end
    end

    details do
      details = default_details.merge(changelog_details)
      details.merge!('comment' => { 'body' => comment_body }) if comment_body
      details
    end

    initialize_with { new(attributes) }

    trait :to_do do
      changelog_details(
        'changelog' => {
          'items' => [{ 'field' => 'status', 'toString' => 'To Do' }],
        },
      )
      status 'To Do'
    end

    trait :in_progress do
      changelog_details(
        'changelog' => {
          'items' => [{ 'field' => 'status', 'toString' => 'In Progress' }],
        },
      )
      status 'In Progress'
    end

    trait :ready_for_review do
      changelog_details(
        'changelog' => {
          'items' => [{ 'field' => 'status', 'toString' => 'Ready For Review' }],
        },
      )
      status 'Ready For Review'
    end

    trait :done do
      changelog_details(
        'changelog' => {
          'items' => [{ 'field' => 'status', 'toString' => 'Done' }],
        },
      )
      status 'Done'
    end
  end
end
# rubocop:enable Style/BlockDelimiters
