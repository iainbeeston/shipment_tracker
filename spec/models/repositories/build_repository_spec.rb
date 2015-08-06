require 'rails_helper'

RSpec.describe Repositories::BuildRepository do
  subject(:repository) { Repositories::BuildRepository.new }

  describe '#builds_for' do
    context 'before an update' do
      it 'returns the state for the apps referenced' do
        events = [create(:circle_ci_event), create(:circle_ci_event), create(:circle_ci_event)]

        results = repository.builds_for(
          apps: {
            'ap1' => 'abc',
            'ap2' => 'ghi',
          },
        )

        expect(results[:builds]).to eq([])
        expect(results[:events].to_a).to eq(events)
      end
    end

    context 'after an update' do
      it 'returns the state for the apps referenced' do
        create(:circle_ci_event, success?: true,  version: 'abc')
        create(:circle_ci_event, success?: true,  version: 'def')
        create(:circle_ci_event, success?: true,  version: 'xyz')
        create(:circle_ci_event, success?: false, version: 'abc')

        repository.update

        result = repository.builds_for(
          apps: {
            'ap1' => 'abc',
            'ap2' => 'xyz',
          },
        )

        expect(result[:builds]).to contain_exactly(
          Build.new(source: 'CircleCi', success: true, version: 'xyz'),
          Build.new(source: 'CircleCi', success: false, version: 'abc'),
        )
        expect(result[:events].to_a).to eq([])
      end
    end

    context 'with at specified' do
      it 'returns the state at that moment' do
        create(:circle_ci_event, success?: true, version: 'abc', created_at: 3.hours.ago)
        create(:circle_ci_event, success?: true, version: 'def', created_at: 2.hours.ago)
        create(:circle_ci_event, success?: false, version: 'abc', created_at: 1.hours.ago)
        create(:circle_ci_event, success?: false, version: 'def', created_at: Time.current)

        repository.update

        result = repository.builds_for(
          apps: {
            'ap1' => 'abc',
            'ap2' => 'def',
          },
          at: 2.hours.ago,
        )

        expect(result[:builds]).to contain_exactly(
          Build.new(source: 'CircleCi', success: true, version: 'abc'),
          Build.new(source: 'CircleCi', success: true, version: 'def'),
        )
        expect(result[:events].to_a).to eq([])
      end
    end

    context 'with at specified but repository not up-to-date' do
      it 'returns the state at that moment and new events up to that moment' do
        create(:circle_ci_event, version: '2', success?: false, created_at: 3.hours.ago)

        repository.update

        expected_event = create(:circle_ci_event, version: '2', success?: true, created_at: 2.hours.ago)
        create(:circle_ci_event, version: '2', success?: true, created_at: 1.minute.ago)

        result = repository.builds_for(
          apps: { 'ap1' => '2' },
          at: 1.hour.ago,
        )

        expect(result[:builds]).to contain_exactly(
          Build.new(source: 'CircleCi', version: '2', success: false),
        )
        expect(result[:events].to_a).to eq([expected_event])
      end
    end
  end
end
