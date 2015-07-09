require 'rails_helper'

require 'support/shared_examples/tickets_projection_examples'

RSpec.describe Projections::ReleasesTicketsProjection do
  subject(:projection) { described_class.new }

  it_behaves_like 'a tickets projection'

  describe '#ticket_for' do
    it 'returns a ticket that matches the jira key' do
      projection.apply(build(:jira_event, key: 'JIRA-1'))
      projection.apply(build(:jira_event, key: 'JIRA-12'))
      projection.apply(build(:jira_event, key: 'JIRA-123'))

      expect(projection.ticket_for('JIRA-123')).to eq(Ticket.new(key: 'JIRA-123'))
    end
  end
end
