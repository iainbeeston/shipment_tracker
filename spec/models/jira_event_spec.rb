require 'rails_helper'

RSpec.describe JiraEvent do
  describe '#status_changed_from?(previous_status)' do
    it 'returns true if the issue status has changed from previous_status' do
      expect(build(:jira_event, :in_progress).status_changed_from?('Done')).to be false
      expect(build(:jira_event, :rejected).status_changed_from?('Done')).to be true
    end
  end

  describe '#status_changed_to?(new_status)' do
    it 'returns true if the issue status has changed to new_status' do
      expect(build(:jira_event, :in_progress).status_changed_to?('Done')).to be false
      expect(build(:jira_event, :done).status_changed_to?('Done')).to be true
    end
  end
end
