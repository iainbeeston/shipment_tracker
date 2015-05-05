require 'rails_helper'
require 'feature_audit_projection'

RSpec.describe FeatureAuditProjection do
  let(:git_repository) { class_double(GitRepository) }

  describe "#tickets" do
    subject(:tickets) {
      described_class.new(
        app_name: 'app_name',
        from: 'a_commit',
        to: 'another_commit',
        git_repository: git_repository
      ).tickets
    }

    let(:commits) do
      commit_messages.map { |message| build(:git_commit, message: message) }
    end

    before do
      allow(git_repository).to receive(:commits_for)
        .with(repository_name: 'app_name', from: 'a_commit', to: 'another_commit')
        .and_return(commits)
    end

    context "when there are multiple valid tickets" do
      let(:commit_messages) do
        [
          'FL-1 at the start',
          'In the GII-312312 middle',
          'At the end ERBB-845',
          'Multiple tickets FL-2, FL-3, FL-4 and FL-5'
        ]
      end

      it { is_expected.to match_array(%w(FL-1 FL-2 FL-3 FL-4 FL-5 GII-312312 ERBB-845)) }
    end

    context "when there are multiple invalid tickets" do
      let(:commit_messages) do
        [
          'Invalid ticket with digits F99-123',
          'bar-123 invalid lowercase ticket',
          'Invalid ticket min char length E-123',
          'A long word with a ticketE-123in the middle',
          'A short one F-123',
          'A wrong separator BAR_123',
          'Letters in the ticket number BAR-123bar456',
          'Ticket without number BAR-',
          'Ticket with number at start 0BAR-123',
        ]
      end

      it { is_expected.to match_array([]) }
    end
  end
end
