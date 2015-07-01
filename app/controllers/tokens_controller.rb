class TokensController < ApplicationController
  def index
    @token = Token.new
    @tokens = Token.all
  end

  def create
    Token.create(source: params[:token][:source])

    redirect_to tokens_path
  end

  def destroy
    Token.revoke(params[:id].to_i)

    redirect_to tokens_path
  end
end
