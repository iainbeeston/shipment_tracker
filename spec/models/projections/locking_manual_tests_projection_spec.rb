require 'rails_helper'
require 'support/shared_examples/locking_projection_examples'

RSpec.describe Projections::LockingManualTestsProjection do
  let(:apps) { { 'frontend' => 'abc', 'backend' => 'def' } }
  let(:defaults) { { accepted: true, email: 'alice@example.com', comment: 'LGTM', apps: apps } }
  let(:projection_url) { feature_review_url(apps) }
  let(:feature_review_location) { FeatureReviewLocation.new(projection_url) }

  subject(:projection) { Projections::LockingManualTestsProjection.new(feature_review_location) }

  it_behaves_like 'a locking projection' do
    context 'when no locking occurs' do
      it 'projects last QA submission' do
        projection.apply(build(:manual_test_event, defaults))
        expect(projection.qa_submission).to eq(QaSubmission.new(defaults))

        projection.apply(build(:manual_test_event, defaults.merge(comment: 'Fab')))
        expect(projection.qa_submission).to eq(QaSubmission.new(defaults.merge(comment: 'Fab')))
      end
    end

    context 'when it becomes locked' do
      it 'projects the last QA submission before it became locked' do
        expected_qa_submission = QaSubmission.new(defaults)

        projection.apply(build(:manual_test_event, defaults))
        expect(projection.qa_submission).to eq(expected_qa_submission)

        projection.apply(lock_event)
        expect(projection.qa_submission).to eq(expected_qa_submission)

        projection.apply(build(:manual_test_event, defaults.merge(comment: 'Fab')))
        expect(projection.qa_submission).to eq(expected_qa_submission)
      end
    end

    context 'when it becomes unlocked' do
      it 'projects the last QA submission' do
        projection.apply(build(:manual_test_event, defaults))
        projection.apply(lock_event)
        projection.apply(build(:manual_test_event, defaults.merge(comment: 'Fab')))
        projection.apply(unlock_event)

        expect(projection.qa_submission).to eq(QaSubmission.new(defaults.merge(comment: 'Fab')))
      end
    end
  end

  it 'reports a failure when a QA rejects the feature review' do
    projection.apply(build(:manual_test_event, defaults.merge(accepted: false)))
    expect(projection.qa_submission).to eq(QaSubmission.new(defaults.merge(accepted: false)))
  end
end
