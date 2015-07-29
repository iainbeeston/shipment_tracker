require 'rails_helper'

RSpec.describe Projections::ManualTestsProjection do
  let(:apps) { { 'frontend' => 'abc', 'backend' => 'def' } }

  subject(:projection) { Projections::ManualTestsProjection.new(apps: apps) }

  context 'test status is failure' do
    let(:events) {
      [
        build(:manual_test_event,
          success?: true,
          email: 'alice@example.com',
          comment: 'LGTM',
          apps: {
            'frontend' => 'abc',
            'backend' => 'def',
          }),
        build(:manual_test_event,
          success?: false,
          email: 'benjamin@example.com',
          comment: 'Nonsense',
          apps: {
            'frontend' => 'abc',
            'backend' => 'def',
          }),
        build(:manual_test_event,
          success?: false,
          email: 'carol@example.com',
          comment: 'Disgusting',
          apps: {
            'frontend' => 'abc',
            'backend' => 'ghi',
          }),
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
          apps: {
            'frontend' => 'abc',
            'backend' => 'def',
          }),
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
