require 'rails_helper'

RSpec.describe Projections::ManualTestsProjection do
  let(:apps) { { 'frontend' => 'abc', 'backend' => 'def' } }
  let(:defaults) { { accepted: true, email: 'alice@example.com', comment: 'LGTM', apps: apps } }

  subject(:projection) { Projections::ManualTestsProjection.new(apps: apps) }

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
