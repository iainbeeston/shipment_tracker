require 'spec_helper'
require 'feature_review_location'

RSpec.describe FeatureReviewLocation do
  subject(:instance) { FeatureReviewLocation.new(url) }

  describe '.from_text' do
    context 'when given text that contains links to Feature Reviews' do
      it 'returns an array of FeatureReviewLocations' do
        expect(
          FeatureReviewLocation.from_text(
            <<-EOS
            missing path http://localhost/not_important?apps[junk]=999
            unparsable http://foo.io/path#bad]
            complex feature review #{full_url('other=true&apps[app1]=abc&apps[app2]=def')}
            simple feature review #{full_url('apps[app1]=abc')}
            EOS
          ),
        ).to match_array([
          FeatureReviewLocation.new(full_url('other=true&apps[app1]=abc&apps[app2]=def')),
          FeatureReviewLocation.new(full_url('apps[app1]=abc')),
        ])
      end
    end
  end

  describe '#versions' do
    let(:url) { full_url('other=true&apps[app1]=xxx&apps[app2]=yyy') }

    subject { instance.versions }

    it { is_expected.to match_array(%w(xxx yyy)) }
  end

  describe '#app_versions' do
    let(:url) { full_url('other=true&apps[app1]=xxx&apps[app2]=yyy') }

    subject { instance.app_versions }

    it { is_expected.to eq(app1: 'xxx', app2: 'yyy') }
  end

  describe '#==' do
    it 'equality is based on fields not identity' do
      instance = described_class.new(full_url('other=true&apps[app1]=xxx&apps[app2]=yyy'))

      expect(described_class.new(full_url('other=true&apps[app1]=xxx&apps[app2]=yyy'))).to eq(instance)

      expect(described_class.new(full_url('apps[app1]=xxx&apps[app2]=yyy'))).to_not eq(instance)
      expect(described_class.new(full_url('other=true&apps[app2]=yyy&apps[app1]=xxx'))).to_not eq(instance)
    end
  end

  describe '#uri' do
    let(:url) { full_url('other=true&apps[app1]=xxx&apps[app2]=yyy') }

    subject { instance.url }

    it { is_expected.to eq(url) }
  end

  describe '#path' do
    let(:url) { full_url('other=true&apps[app1]=xxx&apps[app2]=yyy') }

    subject { instance.path }

    it { is_expected.to eq('/feature_reviews?other=true&apps[app1]=xxx&apps[app2]=yyy') }
  end

  describe '#uat_url' do
    let(:url) { full_url('other=true&apps[app1]=xxx&apps[app2]=yyy&uat_url=http%3A%2F%2Ffoo.com') }

    subject { instance.uat_url }

    it { is_expected.to eq('http://foo.com') }
  end

  def full_url(query)
    "http://localhost/feature_reviews?#{query}"
  end
end
