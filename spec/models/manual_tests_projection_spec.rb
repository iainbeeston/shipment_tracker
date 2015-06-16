require 'rails_helper'

RSpec.describe ManualTestsProjection do
  let(:apps) { { 'frontend' => 'abc', 'backend' => 'def' } }

  subject(:projection) { ManualTestsProjection.new(apps: apps) }

  context 'test status is failure' do
    let(:events) {
      [
        build(:manual_test_event,
          status: 'success',
          name: 'Alice',
          apps: [
            { name: 'frontend', version: 'abc' },
            { name: 'backend', version: 'def' },
          ]),
        build(:manual_test_event,
          status: 'failed',
          name: 'Benjamin',
          apps: [
            { name: 'frontend', version: 'abc' },
            { name: 'backend', version: 'def' },
          ]),
        build(:manual_test_event,
          status: 'failed',
          name: 'Carol',
          apps: [
            { name: 'frontend', version: 'abc' },
            { name: 'backend', version: 'ghi' },
          ]),
      ]
    }

    it 'returns the last QA submission for the specified apps' do
      events.each do |event|
        projection.apply(event)
      end

      expect(projection.qa_submission).to eq(
        QaSubmission.new(
          status: 'rejected',
          name: 'Benjamin',
        ),
      )
    end
  end

  context 'test status is success' do
    let(:events) {
      [
        build(:manual_test_event,
          status: 'success',
          name: 'Alice',
          apps: [
            { name: 'frontend', version: 'abc' },
            { name: 'backend', version: 'def' },
          ]),
      ]
    }

    it 'returns the last QA submission for the specified apps' do
      events.each do |event|
        projection.apply(event)
      end

      expect(projection.qa_submission).to eq(
        QaSubmission.new(
          status: 'accepted',
          name: 'Alice',
        ),
      )
    end
  end
end
