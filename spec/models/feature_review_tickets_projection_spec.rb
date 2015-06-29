require 'rails_helper'

RSpec.describe FeatureReviewTicketsProjection do
  let(:projection_url) { Support::FeatureReviewUrl.build(app1: 'abc') }

  subject(:projection) { FeatureReviewTicketsProjection.new(projection_url: projection_url) }

  let(:jira_1) { { key: 'JIRA-1', summary: 'Ticket 1' } }
  let(:jira_4) { { key: 'JIRA-4', summary: 'Ticket 4' } }

  let(:events) {
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
    ]
  }

  it 'projects the tickets referenced in JIRA comments' do
    events.each do |event|
      projection.apply(event)
    end

    expect(projection.tickets).to eq([
      Ticket.new(key: 'JIRA-1', summary: 'Ticket 1', status: 'Done'),
      Ticket.new(key: 'JIRA-4', summary: 'Ticket 4', status: 'Ready For Review'),
    ])
  end

  it 'ignores non JIRA issue events' do
    event = build(:jira_event_user_created)

    expect { projection.apply(event) }.to_not raise_error
  end

  context 'when multiple feature reviews are referenced in the same JIRA ticket' do
    let(:events) {
      [
        build(:jira_event, key: 'JIRA-1', comment_body: "Review #{url1}"),
        build(:jira_event, key: 'JIRA-1', comment_body: "Review again #{url2}"),
      ]
    }
    let(:url1) { Support::FeatureReviewUrl.build(app1: 'one') }
    let(:url2) { Support::FeatureReviewUrl.build(app2: 'two') }

    subject(:projection1) { FeatureReviewTicketsProjection.new(projection_url: url1) }
    subject(:projection2) { FeatureReviewTicketsProjection.new(projection_url: url2) }

    it 'projects the ticket referenced in the JIRA comments for each projection' do
      events.each do |event|
        projection1.apply(event)
        projection2.apply(event)
      end

      expect(projection1.tickets).to eq([Ticket.new(key: 'JIRA-1')])
      expect(projection2.tickets).to eq([Ticket.new(key: 'JIRA-1')])
    end
  end
end
