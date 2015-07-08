require 'spec_helper'
require 'feature_review_location'

require 'addressable/uri'

RSpec.describe FeatureReviewLocation do
  subject(:instance) { FeatureReviewLocation.new(url) }

  describe '.from_text' do
    let(:url1) { full_url('other' => 'true', 'apps[app1]' => 'a', 'apps[app2]' => 'b') }
    let(:url2) { full_url('apps[app1]' => 'a') }

    let(:text) {
      <<-EOS
        complex feature review #{url1}
        simple feature review #{url2}
      EOS
    }

    subject(:feature_review_locations) { FeatureReviewLocation.from_text(text) }

    it 'returns an array of FeatureReviewLocations for each URL in the given text' do
      expect(feature_review_locations).to match_array([
        FeatureReviewLocation.new(url1),
        FeatureReviewLocation.new(url2),
      ])
    end

    context 'when a URL has an irrelevant path' do
      let(:text) { 'irrelevant path http://localhost/not_important?apps[junk]=999' }

      it 'ignores it' do
        expect(feature_review_locations).to be_empty
      end
    end

    context 'when a URL is unparseable' do
      let(:text) { 'unparseable http://foo.io/path#bad]' }

      it 'ignores it' do
        expect(feature_review_locations).to be_empty
      end
    end
  end

  describe '#versions' do
    let(:url) { full_url('other' => 'true', 'apps[app1]' => 'xxx', 'apps[app2]' => 'yyy') }

    subject { instance.versions }

    it { is_expected.to match_array(%w(xxx yyy)) }
  end

  describe '#app_versions' do
    let(:url) { full_url('other' => 'true', 'apps[app1]' => 'xxx', 'apps[app2]' => 'yyy') }

    subject { instance.app_versions }

    it { is_expected.to eq(app1: 'xxx', app2: 'yyy') }
  end

  describe '#==' do
    it 'equality is based on fields not identity' do
      url = full_url([%w(other true), %w(apps[app1] xxx), %w(apps[app2] yyy)])
      url_order = full_url([%w(other true), %w(apps[app2] yyy), %w(apps[app1] xxx)])
      url_missing = full_url('apps[app1]' => 'xxx', 'apps[app2]' => 'yyy')

      expect(described_class.new(url)).to eq(described_class.new(url))

      expect(described_class.new(url_missing)).to_not eq(described_class.new(url))
      expect(described_class.new(url)).to_not eq(described_class.new(url_order))
    end
  end

  describe '#uri' do
    let(:url) { full_url('other' => 'true', 'apps[app1]' => 'xxx', 'apps[app2]' => 'yyy') }

    subject { instance.url }

    it { is_expected.to eq(url) }
  end

  describe '#path' do
    let(:url) { full_url([%w(other true), %w(apps[app1] xxx), %w(apps[app2] yyy)]) }

    subject { instance.path }

    it { is_expected.to eq('/feature_reviews?other=true&apps%5Bapp1%5D=xxx&apps%5Bapp2%5D=yyy') }
  end

  describe '#uat_url' do
    let(:url) { full_url('apps[app1]' => 'xxx', 'apps[app2]' => 'yyy', 'uat_url' => 'http://foo.com') }

    subject { instance.uat_url }

    it { is_expected.to eq('http://foo.com') }
  end

  def full_url(query_values)
    Addressable::URI.new(
      scheme: 'http',
      host:   'localhost',
      path:   '/feature_reviews',
      query_values: query_values,
    ).to_s
  end
end
