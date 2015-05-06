shared_examples "a test build interface" do
  it { is_expected.to respond_to(:source) }
  it { is_expected.to respond_to(:version) }
  it { is_expected.to respond_to(:status) }
end

shared_examples "a test build subclass" do
  describe '#source' do
    let(:payload) { success_payload }
    it { expect(subject.source).to eql(expected_source) }
  end

  describe '#status' do
    context 'when a failure' do
      let(:payload) { failure_payload }
      it { expect(subject.status).to eql('failed') }
    end

    context 'when a success' do
      let(:payload) { success_payload }
      it { expect(subject.status).to eql('success') }
    end

    context 'when invalid' do
      let(:payload) { invalid_payload }
      it { expect(subject.status).to eql('unknown') }
    end
  end

  describe '#version' do
    context 'when a failure' do
      let(:payload) { failure_payload }
      it { expect(subject.version).to eql(version) }
    end

    context 'when a success' do
      let(:payload) { success_payload }
      it { expect(subject.version).to eql(version) }
    end

    context 'when invalid' do
      let(:payload) { invalid_payload }
      it { expect(subject.version).to eql('unknown') }
    end
  end
end
