# rubocop:disable Style/BlockDelimiters
require 'rails_helper'

RSpec.describe DeployEvent do
  subject { DeployEvent.new(details: payload) }

  context 'when given a valid payload' do
    context 'when given a single server' do
      let(:payload) {
        {
          'app_name' => 'soMeApp',
          'server' => 'uat.example.com',
          'version' => '123',
          'deployed_by' => 'bob',
        }
      }

      its(:app_name) { is_expected.to eq('someapp') }
      its(:server) { is_expected.to eq('uat.example.com') }
      its(:version) { is_expected.to eq('123') }
      its(:deployed_by) { is_expected.to eq('bob') }
    end

    context 'when given multiple servers' do
      let(:payload) {
        {
          'app_name' => 'soMeApp',
          'servers' => ['prod1.example.com', 'prod2.example.com'],
          'version' => '123',
          'deployed_by' => 'bob',
        }
      }
      its(:app_name) { is_expected.to eq('someapp') }
      its(:server) { is_expected.to eq('prod1.example.com') }
      its(:version) { is_expected.to eq('123') }
      its(:deployed_by) { is_expected.to eq('bob') }
    end
  end

  context 'when given an invalid payload' do
    let(:payload) {
      {
        'bad' => 'news',
      }
    }

    its(:app_name) { is_expected.to be_nil }
    its(:server) { is_expected.to be_nil }
    its(:version) { is_expected.to be_nil }
    its(:deployed_by) { is_expected.to be_nil }
  end
end
# rubocop:enable Style/BlockDelimiters
