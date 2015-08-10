require 'rails_helper'
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

    context 'when a URL contains an unknown schema' do
      let(:text) { 'foo:/feature_reviews' }

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
    let(:url) {
      full_url(
        'other' => 'true',
        'apps[app1]' => 'xxx',
        'apps[app2]' => 'yyy',
        'apps[app3]' => '',
      )
    }

    subject { instance.app_versions }

    it { is_expected.to eq('app1' => 'xxx', 'app2' => 'yyy') }
  end

  describe '#==' do
    it 'equality is based on fields not identity' do
      url_args = [%w(apps[app1] xxx), %w(apps[app2] yyy), %w(uat_url http://uat.com)]
      url = full_url(url_args)

      same = {
        order:       full_url(url_args.reverse),
        extra_app:   full_url(url_args.concat([['apps[app3]', '']])),
        extra_param: full_url(url_args.concat([%w(irrelevant value)])),
        no_scheme:   full_url([%w(apps[app1] xxx), %w(apps[app2] yyy), %w(uat_url uat.com)]),
      }

      different = {
        different_version: full_url([%w(apps[app1] abc), %w(apps[app2] yyy), %w(uat_url http://uat.com)]),
        different_uat_url: full_url([%w(apps[app1] abc), %w(apps[app2] yyy), %w(uat_url http://foobar.com)]),
        different_no_uat:  full_url([%w(apps[app1] abc), %w(apps[app2] yyy)]),
      }

      aggregate_failures do
        same.each do |name, same_url|
          expect(FeatureReviewLocation.new(url)).to(
            eq(FeatureReviewLocation.new(same_url)),
            "#{name} did not match when it should have",
          )
        end

        different.each do |name, different_url|
          expect(FeatureReviewLocation.new(url)).to_not(
            eq(FeatureReviewLocation.new(different_url)),
            "#{name} matched when it should not have",
          )
        end
      end
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

  describe '#uat_host' do
    let(:url) { full_url('uat_url' => 'http://foo.com') }

    subject { instance.uat_host }

    it { is_expected.to eq('foo.com') }

    context 'when scheme is missing' do
      let(:url) { full_url('uat_url' => 'foo.com') }
      it { is_expected.to eq('foo.com') }
    end

    context 'when uat_url is missing' do
      let(:url) { full_url('uat_url' => '') }
      it { is_expected.to be_nil }
    end
  end

  describe '#uat_url' do
    let(:url) { full_url('apps[app1]' => 'xxx', 'apps[app2]' => 'yyy', 'uat_url' => 'http://foo.com') }

    subject { instance.uat_url }

    it { is_expected.to eq('http://foo.com') }

    context 'when scheme is missing' do
      let(:url) { full_url('uat_url' => 'foo.com') }
      it { is_expected.to eq('http://foo.com') }
    end

    context 'when uat_url is missing' do
      let(:url) { full_url('uat_url' => '') }
      it { is_expected.to be_nil }
    end
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
