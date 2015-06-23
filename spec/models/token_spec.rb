require 'rails_helper'

RSpec.describe Token do
  describe '.create' do
    it 'autogenerates a value' do
      value = Token.create(source: 'foo').value

      expect(value).to be_a(String)
      expect(value.length).to eq(24)
    end
  end

  describe '.valid?' do
    before do
      Token.create(source: 'circleci', value: 'abc123')
      Token.create(source: 'circleci', value: 'def456')
      Token.create(source: 'circleci', value: nil)
    end

    context 'with a valid token' do
      it 'returns true' do
        expect(Token.valid?('circleci', 'abc123')).to be true
        expect(Token.valid?('circleci', 'def456')).to be true
      end
    end

    context 'with an invalid token' do
      it 'returns false' do
        expect(Token.valid?('circleci', 'xyz789')).to be false
      end
    end

    context 'with a nil token' do
      it 'returns false' do
        expect(Token.valid?('circleci', nil)).to be false
      end
    end
  end
end
