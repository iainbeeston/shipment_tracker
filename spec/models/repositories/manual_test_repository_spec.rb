require 'rails_helper'

RSpec.describe Repositories::ManualTestRepository do
  subject(:repository) { Repositories::ManualTestRepository.new }

  describe '#qa_submission_for' do
    context 'before an update' do
      it 'returns the state for the apps referenced' do
        events = [create(:manual_test_event), create(:manual_test_event), create(:manual_test_event)]

        results = repository.qa_submission_for(
          apps: {
            'ap1' => 'abc',
            'ap2' => 'ghi',
          },
        )

        expect(results[:qa_submission]).to eq(nil)
        expect(results[:events].to_a).to eq(events)
      end
    end

    context 'after an update' do
      it 'returns the state for the apps referenced' do
        default = { apps: { 'ap1' => 'abc', 'ap2' => 'def' }, email: 'foo@ex.io', comment: 'Good' }

        t = [4.hours.ago, 3.hours.ago, 2.hours.ago, 1.hour.ago]
        create(:manual_test_event, default.merge(accepted: false, created_at: t[0]))
        create(:manual_test_event, default.merge(apps: { 'ap2' => 'def' }, accepted: false, created_at: t[1]))
        create(:manual_test_event, default.merge(accepted: true, created_at: t[2]))
        create(:manual_test_event, default.merge(apps: { 'ap1' => 'abc' }, accepted: false, created_at: t[3]))

        repository.update

        result = repository.qa_submission_for(
          apps: {
            'ap1' => 'abc',
            'ap2' => 'def',
          },
        )

        expect(result[:qa_submission]).to eq(
          QaSubmission.new(email: 'foo@ex.io', accepted: true, comment: 'Good', created_at: t[2]),
        )
        expect(result[:events].to_a).to eq([])
      end
    end

    context 'with at specified' do
      it 'returns the state at that moment' do
        default = { apps: { 'ap1' => 'abc', 'ap2' => 'def' }, email: 'foo@ex.io', comment: 'Good' }

        times = [3.hours.ago, 2.hours.ago, 1.hour.ago]
        create(:manual_test_event, default.merge(accepted: false, created_at: times[0]))
        create(:manual_test_event, default.merge(accepted: true, created_at: times[1]))
        create(:manual_test_event, default.merge(accepted: false, created_at: times[2]))

        repository.update

        result = repository.qa_submission_for(
          apps: {
            'ap1' => 'abc',
            'ap2' => 'def',
          },
          at: 2.hours.ago,
        )

        expect(result[:qa_submission]).to eq(
          QaSubmission.new(email: 'foo@ex.io', accepted: true, comment: 'Good', created_at: times[1]),
        )
        expect(result[:events].to_a).to eq([])
      end
    end

    context 'with at specified but repository not up-to-date' do
      it 'returns the state at that moment and new events up to that moment' do
        defaults = { apps: { 'ap1' => '2' }, email: 'foo@ex.io', comment: 'Good' }
        times = [3.hours.ago, 2.hours.ago, 1.minute.ago]

        create(:manual_test_event, defaults.merge(accepted: false, created_at: times[0]))

        repository.update

        expected_event = create(:manual_test_event, defaults.merge(accepted: true, created_at: times[1]))
        create(:manual_test_event, defaults.merge(accepted: false, created_at: times[2]))

        result = repository.qa_submission_for(
          apps: { 'ap1' => '2' },
          at: 1.hour.ago,
        )

        expect(result[:qa_submission]).to eq(
          QaSubmission.new(email: 'foo@ex.io', accepted: false, comment: 'Good', created_at: times[0]),
        )
        expect(result[:events].to_a).to eq([expected_event])
      end
    end
  end
end
