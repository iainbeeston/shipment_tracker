require 'rails_helper'

RSpec.describe FeatureReview do
  let(:base_url) { 'http://localhost/feature_reviews' }

  describe '#==' do
    it 'equality is based on fields not identity' do
      original = FeatureReview.new(
        url: "#{base_url}?uat_url=http://uat.com&apps%5Bapp1%5D=xxx&apps%5Bapp2%5D=yyy",
        versions: %w(xxx yyy),
      )

      same = {
        order: FeatureReview.new(
          url: "#{base_url}?apps%5Bapp2%5D=yyy&apps%5Bapp1%5D=xxx&uat_url=http://uat.com",
          versions: %w(xxx yyy)),
        extra_param: FeatureReview.new(
          url: "#{base_url}?uat_url=http://uat.com&apps%5Bapp1%5D=xxx&apps%5Bapp2%5D=yyy&irrelevant=value",
          versions: %w(xxx yyy)),
        no_scheme: FeatureReview.new(
          url: "#{base_url}?uat_url=uat.com&apps%5Bapp1%5D=xxx&apps%5Bapp2%5D=yyy",
          versions: %w(xxx yyy)),
      }

      different = {
        different_version: FeatureReview.new(
          url: "#{base_url}?uat_url=http://uat.com&apps%5Bapp1%5D=abc&apps%5Bapp2%5D=yyy",
          versions: %w(abc yyy)),
        different_uat_url: FeatureReview.new(
          url: "#{base_url}?uat_url=http://foobar.com&apps%5Bapp1%5D=xxx&apps%5Bapp2%5D=yyy",
          versions: %w(xxx yyy)),
        different_no_uat: FeatureReview.new(
          url: "#{base_url}?apps%5Bapp1%5D=xxx&apps%5Bapp2%5D=yyy",
          versions: %w(xxx yyy)),
      }

      aggregate_failures do
        same.each do |name, same_feature_review|
          expect(original).to(
            eq(same_feature_review),
            "#{name} did not match when it should have",
          )
        end

        different.each do |name, different_feature_review|
          expect(original).to_not(
            eq(different_feature_review),
            "#{name} matched when it should not have",
          )
        end
      end
    end
  end

  describe '#path' do
    let(:url) { "#{base_url}?uat_url=http://uat.com&apps%5Bapp1%5D=xxx&apps%5Bapp2%5D=yyy" }

    subject { FeatureReview.new(url: url, versions: %w(xxx yyy)).path }

    it { is_expected.to eq('/feature_reviews?uat_url=http://uat.com&apps%5Bapp1%5D=xxx&apps%5Bapp2%5D=yyy') }
  end

  describe '#uat_host' do
    let(:url) { "#{base_url}?uat_url=http://uat.com&apps%5Bapp1%5D=xxx&apps%5Bapp2%5D=yyy" }

    subject { FeatureReview.new(url: url, versions: %w(xxx yyy)).uat_host }

    it { is_expected.to eq('uat.com') }

    context 'when scheme is missing' do
      let(:url) { "#{base_url}?uat_url=uat.com&apps%5Bapp1%5D=xxx&apps%5Bapp2%5D=yyy" }
      it { is_expected.to eq('uat.com') }
    end

    context 'when uat_url is missing' do
      let(:url) { "#{base_url}?apps%5Bapp1%5D=xxx&apps%5Bapp2%5D=yyy" }
      it { is_expected.to be_nil }
    end
  end

  describe '#uat_url' do
    let(:url) { "#{base_url}?uat_url=http://uat.com&apps%5Bapp1%5D=xxx&apps%5Bapp2%5D=yyy" }

    subject { FeatureReview.new(url: url, versions: %w(xxx yyy)).uat_url }

    it { is_expected.to eq('http://uat.com') }

    context 'when scheme is missing' do
      let(:url) { "#{base_url}?uat_url=uat.com&apps%5Bapp1%5D=xxx&apps%5Bapp2%5D=yyy" }
      it { is_expected.to eq('http://uat.com') }
    end

    context 'when uat_url is missing' do
      let(:url) { "#{base_url}?apps%5Bapp1%5D=xxx&apps%5Bapp2%5D=yyy" }
      it { is_expected.to be_nil }
    end
  end

  describe '#app_versions' do
    let(:url) { "#{base_url}?apps%5Bapp1%5D=xxx&apps%5Bapp2%5D=yyy&apps%5Bapp3%5D" }

    subject { FeatureReview.new(url: url, versions: %w(xxx yyy)).app_versions }

    it { is_expected.to eq('app1' => 'xxx', 'app2' => 'yyy') }
  end
end
