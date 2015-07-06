require 'rails_helper'

RSpec.describe ManualTestsProjection do
  let(:apps) { { 'frontend' => 'abc', 'backend' => 'def' } }

  subject(:projection) { ManualTestsProjection.new(apps: apps) }

  context 'test status is failure' do
    let(:events) {
      [
        build(:manual_test_event,
          success?: true,
          email: 'alice@example.com',
          comment: 'LGTM',
          apps: [
            { name: 'frontend', version: 'abc' },
            { name: 'backend', version: 'def' },
          ]),
        build(:manual_test_event,
          success?: false,
          email: 'benjamin@example.com',
          comment: 'Nonsense',
          apps: [
            { name: 'frontend', version: 'abc' },
            { name: 'backend', version: 'def' },
          ]),
        build(:manual_test_event,
          success?: false,
          email: 'carol@example.com',
          comment: 'Disgusting',
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
          accepted: false,
          email: 'benjamin@example.com',
          comment: 'Nonsense',
        ),
      )
    end
  end

  context 'test status is success' do
    let(:events) {
      [
        build(:manual_test_event,
          success?: true,
          email: 'alice@example.com',
          comment: 'Fabulous',
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
          accepted: true,
          email: 'alice@example.com',
          comment: 'Fabulous',
        ),
      )
    end
  end
end
