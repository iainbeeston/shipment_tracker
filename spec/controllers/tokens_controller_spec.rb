require 'rails_helper'

RSpec.describe TokensController do
  let(:tokens) { [Token.new] }

  before do
    allow(Token).to receive(:all).and_return(tokens)
  end

  describe 'GET #index', skip_login: true do
    let(:sources) { %w(source-one source-two source-three) }
    let(:event_factory) { instance_double(EventFactory, supported_external_types: sources) }

    before do
      allow(EventFactory).to receive(:build).and_return(event_factory)
    end

    it 'shows the list of tokens' do
      get :index

      expect(assigns(:tokens)).to eq(tokens)
      expect(assigns(:token)).to be_a(Token)
      expect(assigns(:token)).to be_a_new_record
      expect(assigns(:sources)).to eq(sources)
    end
  end

  describe 'POST #create', skip_login: true do
    it 'creates a new token' do
      expect(Token).to receive(:create).with(source: 'circleci', name: 'frontend')

      post :create, token: { source: 'circleci', name: 'frontend' }

      expect(response).to redirect_to(tokens_path)
    end
  end

  describe 'PUT #update', skip_login: true do
    it 'updates a token given a X-editable payload' do
      expect(Token).to receive(:update).with(42, 'name' => 'New name')

      put :update, id: 42, name: 'name', value: 'New name', pk: 42, format: :json
    end
  end

  describe 'DELETE #destroy', skip_login: true do
    it 'revokes a token' do
      expect(Token).to receive(:revoke).with(123)

      delete :destroy, id: 123

      expect(response).to redirect_to(tokens_path)
    end
  end
end
