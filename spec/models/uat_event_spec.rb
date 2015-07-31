# rubocop:disable Style/BlockDelimiters
require 'rails_helper'

RSpec.describe UatEvent do
  subject { UatEvent.new(details: payload) }

  context 'when given a valid payload' do
    let(:payload) {
      {
        'success' => true,
        'test_suite_version' => 'ab91d954a51ddc74e29e7582d9a2efe8bb6d480f',
        'server' => 'uat.example.com',
      }
    }

    its(:test_suite_version) { is_expected.to eq('ab91d954a51ddc74e29e7582d9a2efe8bb6d480f') }
    its(:server) { is_expected.to eq('uat.example.com') }
    its(:success) { is_expected.to be(true) }
  end

  context 'when given an invalid payload' do
    let(:payload) {
      {
        'bad' => 'news',
      }
    }

    its(:test_suite_version) { is_expected.to be_nil }
    its(:server) { is_expected.to be_nil }
    its(:success) { is_expected.to be(false) }
  end
end
# rubocop:enable Style/BlockDelimiters
