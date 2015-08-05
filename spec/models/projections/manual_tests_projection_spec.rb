require 'rails_helper'

RSpec.describe Projections::ManualTestsProjection do
  let(:apps) { { 'frontend' => 'abc', 'backend' => 'def' } }
  let(:defaults) { { accepted: true, email: 'alice@example.com', comment: 'LGTM', apps: apps } }

  subject(:projection) { Projections::ManualTestsProjection.new(apps: apps) }

  describe '.load' do
    let(:repository) { instance_double(Repositories::ManualTestRepository) }
    let(:expected_qa_submission) { QaSubmission.new }
    let(:expected_events) { [Event.new] }
    let(:expected_projection) { instance_double(Projections::ManualTestsProjection) }
    let(:time) { Time.current }

    it 'inflates the projection and feeds it remaining events' do
      allow(repository).to receive(:qa_submission_for)
        .with(apps: apps, at: time)
        .and_return(qa_submission: expected_qa_submission, events: expected_events)

      allow(Projections::ManualTestsProjection).to receive(:new).with(
        apps: apps,
        qa_submission: expected_qa_submission,
      ).and_return(expected_projection)

      expect(expected_projection).to receive(:apply_all).with(expected_events)

      expect(
        Projections::ManualTestsProjection.load(apps: apps, at: time, repository: repository),
      ).to be(expected_projection)
    end
  end

  it 'projects last QA submission' do
    projection.apply(build(:manual_test_event, defaults))
    expect(projection.qa_submission).to eq(QaSubmission.new(defaults))

    projection.apply(build(:manual_test_event, defaults.merge(comment: 'Fab')))
    expect(projection.qa_submission).to eq(QaSubmission.new(defaults.merge(comment: 'Fab')))
  end

  it 'reports a failure when a QA rejects the feature review' do
    projection.apply(build(:manual_test_event, defaults.merge(accepted: false)))
    expect(projection.qa_submission).to eq(QaSubmission.new(defaults.merge(accepted: false)))
  end
end
