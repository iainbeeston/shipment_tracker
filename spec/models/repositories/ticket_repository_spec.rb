require 'rails_helper'

RSpec.describe Repositories::TicketRepository do
  subject(:repository) { Repositories::TicketRepository.new }

  describe '#tickets_for' do
    let(:url) { 'http://foo.com/bar' }

    context 'before an update' do
      it 'returns the state for the projection_url referenced' do
        events = [create(:jira_event), create(:jira_event), create(:jira_event)]

        results = repository.tickets_for(projection_url: url)

        expect(results[:tickets]).to eq([])
        expect(results[:events].to_a).to eq(events)
      end
    end

    context 'after an update' do
      it 'returns the state for the projection_url referenced' do
        default = { summary: 'Job' }

        t = [4.hours.ago, 3.hours.ago, 2.hours.ago, 1.hour.ago, 1.minute.ago]

        create(:jira_event, :created, default.merge(key: 'J-1', comment_body: url, created_at: t[0]))
        create(:jira_event, :approved, default.merge(key: 'J-1', created_at: t[1]))
        create(:jira_event, :created, default.merge(key: 'J-2', created_at: t[2]))
        create(:jira_event, :created, default.merge(key: 'J-2', comment_body: url, created_at: t[3]))
        create(:jira_event, :created, default.merge(key: 'J-3', created_at: t[4]))

        repository.update

        result = repository.tickets_for(projection_url: url)

        expect(result[:tickets]).to match_array([
          Ticket.new(key: 'J-1', summary: 'Job', status: 'Ready for Deployment'),
          Ticket.new(key: 'J-2', summary: 'Job', status: 'To Do'),
        ])
        expect(result[:events].to_a).to eq([])
      end
    end

    context 'with at specified' do
      it 'returns the state at that moment' do
        default = { summary: 'Job' }

        t = [4.hours.ago, 3.hours.ago, 2.hours.ago, 1.hour.ago, 1.minute.ago]

        create(:jira_event, :created, default.merge(key: 'J-1', comment_body: url, created_at: t[0]))
        create(:jira_event, :approved, default.merge(key: 'J-1', created_at: t[1]))
        create(:jira_event, :created, default.merge(key: 'J-2', created_at: t[2]))
        create(:jira_event, :created, default.merge(key: 'J-2', comment_body: url, created_at: t[3]))
        create(:jira_event, :created, default.merge(key: 'J-3', created_at: t[4]))

        repository.update

        result = repository.tickets_for(projection_url: url, at: t[2])

        expect(result[:tickets]).to match_array([
          Ticket.new(key: 'J-1', summary: 'Job', status: 'Ready for Deployment'),
        ])
        expect(result[:events].to_a).to eq([])
      end
    end

    context 'with at specified but repository not up-to-date' do
      it 'returns the state at that moment and new events up to that moment' do
        defaults = { key: 'J-1', summary: 'Job' }

        times = [3.hours.ago, 2.hours.ago, 1.minute.ago]

        create(:jira_event, :created, defaults.merge(comment_body: url, created_at: times[0]))

        repository.update

        expected_event = create(:jira_event, defaults.merge(summary: 'Summary', created_at: times[1]))
        create(:jira_event, :created, defaults.merge(summary: 'New title', created_at: times[2]))

        result = repository.tickets_for(projection_url: url, at: times[1])

        expect(result[:tickets]).to match_array([
          Ticket.new(key: 'J-1', summary: 'Job', status: 'To Do'),
        ])
        expect(result[:events].to_a).to eq([expected_event])
      end
    end
  end
end
