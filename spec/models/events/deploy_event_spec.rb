require 'rails_helper'

RSpec.describe Events::DeployEvent do
  subject { described_class.new(details: payload) }

  context 'when given a valid payload' do
    let(:payload) {
      {
        'app_name' => 'soMeApp',
        'servers' => ['prod1.example.com', 'prod2.example.com'],
        'version' => '123',
        'deployed_by' => 'bob',
      }
    }

    it 'returns the correct values' do
      expect(subject.app_name).to eq('someapp')
      expect(subject.server).to eq('prod1.example.com')
      expect(subject.version).to eq('123')
      expect(subject.deployed_by).to eq('bob')
    end

    context 'when the payload structure is deprecated' do
      let(:payload) {
        {
          'app_name' => 'soMeApp',
          'server' => 'uat.example.com',
          'version' => '123',
          'deployed_by' => 'bob',
        }
      }

      it 'returns the correct values' do
        expect(subject.app_name).to eq('someapp')
        expect(subject.server).to eq('uat.example.com')
        expect(subject.version).to eq('123')
        expect(subject.deployed_by).to eq('bob')
      end
    end
  end

  context 'when given an invalid payload' do
    let(:payload) {
      {
        'bad' => 'news',
      }
    }

    it 'returns the correct values' do
      expect(subject.app_name).to be_nil
      expect(subject.server).to be_nil
      expect(subject.version).to be_nil
      expect(subject.deployed_by).to be_nil
    end
  end
end
