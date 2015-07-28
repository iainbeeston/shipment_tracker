RSpec.shared_examples_for 'a locking projection' do
  def lock_event(overrides = {})
    opts = {
      key: 'JIRA-123', comment_body: "Here you go: #{projection_url}"
    }.merge(overrides)
    build(:jira_event, :deployed, opts)
  end

  def unlock_event(overrides = {})
    opts = {
      key: 'JIRA-123',
    }.merge(overrides)
    build(:jira_event, :rejected, opts)
  end
end
