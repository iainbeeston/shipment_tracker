require 'rails_helper'

RSpec.describe EventFactory do
  describe '#create' do
    let(:payload) { { 'foo' => 'bar' } }
    let(:current_user) { double(:current_user, email: 'foo@bar.com') }
    let(:factory) { EventFactory.new }

    subject { factory.create(event_type, payload, current_user) }

    {
      'deploy'      => DeployEvent,
      'circleci'    => CircleCiEvent,
      'jenkins'     => JenkinsEvent,
      'jira'        => JiraEvent,
      'uat'         => UatEvent,
    }.each do |type, klass|
      context "with the '#{type}' enpoint" do
        let(:event_type) { type }

        it "returns a #{klass} instance" do
          expect(subject).to be_an_instance_of(klass)
        end

        it 'stores the payload in the event details' do
          expect(subject.details).to eq(payload)
        end
      end
    end

    context "with the 'manual_test' event_type" do
      let(:event_type) { 'manual_test' }

      it "returns a ManualTestEvent instance" do
        expect(subject).to be_an_instance_of(ManualTestEvent)
      end

      it 'stores the payload in the event details' do
        expect(subject.details).to eq('foo' => 'bar', 'email' => 'foo@bar.com')
      end
    end

    context 'with an unrecognized event type' do
      let(:event_type) { 'unexistent' }

      it 'raises an error' do
        expect { subject }.to raise_error("Unrecognized event type 'unexistent'")
      end
    end
  end
end
