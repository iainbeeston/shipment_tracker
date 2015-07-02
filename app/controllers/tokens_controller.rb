class TokensController < ApplicationController
  def index
    @token = Token.new
    @tokens = Token.all
    @sources = event_factory.supported_external_types
  end

  def create
    Token.create(token_params)

    redirect_to tokens_path
  end

  def destroy
    Token.revoke(params[:id].to_i)

    redirect_to tokens_path
  end

  private

  def token_params
    params.require(:token).permit(:source, :name)
  end
end
