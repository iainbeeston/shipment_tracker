require 'rails_helper'
require 'support/shared_examples/locking_projection_examples'

RSpec.describe Projections::LockingTicketsProjection do
  let(:projection_url) { feature_review_url(app1: 'abc') }
  let(:feature_review_location) { FeatureReviewLocation.new(projection_url) }

  subject(:projection) { Projections::LockingTicketsProjection.new(feature_review_location) }

  it_behaves_like 'a locking projection' do
    context 'when no locking occurs' do
      it 'projects latest associated tickets' do
        projection.apply(build(:jira_event, :created, key: 'JIRA-1', comment_body: projection_url))
        expect(projection.tickets).to eq([Ticket.new(key: 'JIRA-1', status: 'To Do', summary: '')])

        projection.apply(build(:jira_event, :started, key: 'JIRA-1'))
        expect(projection.tickets).to eq([Ticket.new(key: 'JIRA-1', status: 'In Progress', summary: '')])
      end
    end

    context 'when it becomes locked' do
      it 'projects the latest associated tickets before it became locked' do
        projection.apply(build(:jira_event, key: 'JIRA-123', comment_body: projection_url))
        expect(projection.tickets).to eq([Ticket.new(key: 'JIRA-123', summary: '', status: 'To Do')])

        projection.apply(lock_event)
        expect(projection.tickets).to eq([Ticket.new(key: 'JIRA-123', summary: '', status: 'Done')])

        projection.apply(lock_event(summary: 'after lock'))
        expect(projection.tickets).to eq([Ticket.new(key: 'JIRA-123', summary: '', status: 'Done')])
      end
    end

    context 'when it becomes unlocked' do
      it 'projects the latest associated tickets' do
        projection.apply(build(:jira_event, key: 'JIRA-123', comment_body: projection_url))
        projection.apply(lock_event)
        projection.apply(unlock_event(summary: 'after lock'))

        expect(projection.tickets).to eq([
          Ticket.new(key: 'JIRA-123', summary: 'after lock', status: 'In Progress'),
        ])
      end
    end
  end

  it 'projects the tickets referenced in JIRA comments' do
    jira_1 = { key: 'JIRA-1', summary: 'Ticket 1' }
    jira_4 = { key: 'JIRA-4', summary: 'Ticket 4' }

    [
      build(:jira_event, :created, jira_1),
      build(:jira_event, :started, jira_1),
      build(:jira_event, :development_completed, jira_1.merge(comment_body: "Review #{projection_url}")),

      build(:jira_event, :created, key: 'JIRA-2'),
      build(:jira_event, :created, key: 'JIRA-3', comment_body: "Review #{projection_url}/extra/stuff"),

      build(:jira_event, :created, jira_4),
      build(:jira_event, :started, jira_4),
      build(:jira_event, :development_completed, jira_4.merge(comment_body: "#{projection_url} is ready!")),

      build(:jira_event, :deployed, jira_1),
    ].each do |event|
      projection.apply(event)
    end

    expect(projection.tickets).to eq([
      Ticket.new(key: 'JIRA-1', summary: 'Ticket 1', status: 'Done'),
      Ticket.new(key: 'JIRA-4', summary: 'Ticket 4', status: 'Ready For Review'),
    ])
  end

  it 'ignores non JIRA issue events' do
    expect { projection.apply(build(:jira_event_user_created)) }.to_not raise_error
  end

  context 'when multiple feature reviews are referenced in the same JIRA ticket' do
    let(:location1) { FeatureReviewLocation.new(feature_review_url(app1: 'one')) }
    let(:location2) { FeatureReviewLocation.new(feature_review_url(app2: 'two')) }

    subject(:projection1) { Projections::LockingTicketsProjection.new(location1) }
    subject(:projection2) { Projections::LockingTicketsProjection.new(location2) }

    it 'projects the ticket referenced in the JIRA comments for each projection' do
      [
        build(:jira_event, key: 'JIRA-1', comment_body: "Review #{location1.url}"),
        build(:jira_event, key: 'JIRA-1', comment_body: "Review again #{location2.url}"),
      ].each do |event|
        projection1.apply(event)
        projection2.apply(event)
      end

      expect(projection1.tickets).to eq([Ticket.new(key: 'JIRA-1')])
      expect(projection2.tickets).to eq([Ticket.new(key: 'JIRA-1')])
    end
  end
end
