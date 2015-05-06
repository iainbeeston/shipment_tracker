require 'rails_helper'
require 'feature_audit_projection'

RSpec.describe FeatureAuditProjection do
  let(:git_repository) { class_double(GitRepository) }

  subject(:projection) do
    described_class.new(
      app_name: 'app_name',
      from: 'a_commit',
      to: 'another_commit',
      git_repository: git_repository
    )
  end

  describe "#tickets" do
    let(:commit_messages) do
      [
        'FL-1 at the start',
        'In the GII-3123 middle',
        'At the end ERBB-845',
        'Multiple tickets FL-2, FL-3, FL-4 and FL-5',
        "Merge pull request #1 from FundingCircle/foo\n\nPR Title\nImplements JI-123\nRelated to JI-111",
      ]
    end

    let(:commits) do
      commit_messages.map { |message| build(:git_commit, message: message) }
    end

    before do
      allow(git_repository).to receive(:commits_for)
        .with(repository_name: 'app_name', from: 'a_commit', to: 'another_commit')
        .and_return(commits)
    end

    it "returns the list of tickets for the feature audit" do
      expect(projection.tickets).to match_array(%w(FL-1 FL-2 FL-3 FL-4 FL-5 GII-3123 ERBB-845 JI-123 JI-111))
    end

    context "when there are multiple commits for the same ticket" do
      let(:commit_messages) do
        [
          'FL-1 at the start',
          'FL-2 in the middle',
          'FL-1 again',
        ]
      end

      it "ignores the duplicates" do
        expect(projection.tickets).to match_array(%w(FL-1 FL-2))
      end
    end

    context "when there invalid tickets" do
      let(:commit_messages) do
        [
          'The only valid ticket (FL-123)',
          'Message without ticket',
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

      it "ignores them" do
        expect(projection.tickets).to eq(['FL-123'])
      end
    end
  end
end
