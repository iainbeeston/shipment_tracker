FactoryGirl.define do
  factory :git_commit do
    skip_create

    sequence(:id) { |n| "abc#{n}" }
    author_name "Frank"
    message "A commit"

    initialize_with { new(attributes) }
  end
end
