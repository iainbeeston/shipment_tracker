require 'rails_helper'

describe ManualTestEvent do
  subject(:event) { ManualTestEvent.new(details: details) }

  let(:apps) { [{ 'name' => 'frontend', 'version' => 'abc' }] }
  let(:user_name) { 'Alice' }
  let(:details) {
    {
      'testing_environment' => {
        'apps' => apps,
      },
      'user' => {
        'name' => user_name,
      },
    }
  }

  describe '#apps' do
    it 'returns the apps list' do
      expect(event.apps).to eq(apps)
    end

    context 'when there are no apps' do
      let(:details) { { 'testing_environment' => {} } }

      it 'returns an empty list' do
        expect(event.apps).to eq([])
      end
    end
  end

  describe '#user_name' do
    it 'returns the user name' do
      expect(event.user_name).to eq(user_name)
    end

    context 'when there is no user' do
      let(:details) { {} }

      it 'returns nil' do
        expect(event.user_name).to be_nil
      end
    end
  end
end
