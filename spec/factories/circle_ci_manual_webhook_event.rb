# rubocop:disable Style/BlockDelimiters
FactoryGirl.define do
  factory :circle_ci_manual_webhook_event do
    transient do
      success? true
      sequence(:version)
    end

    details {
      {
        'steps' => [
          { 'name' => 'RSpec',    'actions' => [{ 'status' => 'success' }] },
          { 'name' => 'Cucumber', 'actions' => [{ 'status' => success? ? 'success' : 'failed' }] },
          { 'name' => 'curl ...', 'actions' => [{ 'status' => 'running' }] },
        ],
        'outcome' => nil,
        'status' => 'running',
        'vcs_revision' => version,
      }
    }

    initialize_with { new(attributes) }
  end
end
# rubocop:enable Style/BlockDelimiters
