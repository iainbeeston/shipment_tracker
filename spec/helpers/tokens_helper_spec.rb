require 'rails_helper'

RSpec.describe TokensHelper do
  describe '.token_link' do
    let(:source) { 'jenkins' }
    let(:token) { '123abc' }
    let(:expected_url) { events_url(type: source, token: token) }

    it 'returns the event url for source with token' do
      helper.token_link(source: source, token: token).should eq(expected_url)
    end

    context 'when the source is github_notifications' do
      let(:source) { 'github_notifications' }
      let(:expected_url) { github_notifications_url(token: token) }

      it 'returns the event url for source with token' do
        helper.token_link(source: source, token: token).should eq(expected_url)
      end
    end
  end
end
