FactoryGirl.define do
  factory :deploy_event do
    skip_create

    transient do
      server 'prod.example.com'
      sequence(:version) { |n| "abc#{n}" }
      app_name 'hello_world'
      deployed_at { Time.now.utc.to_i }
      deployed_by 'frank@example.com'
    end

    details {
      {
        'server' => server,
        'version' => version,
        'app_name' => app_name,
        'deployed_at' => deployed_at,
        'deployed_by' => deployed_by
      }
    }

    initialize_with { new(attributes) }
  end
end
