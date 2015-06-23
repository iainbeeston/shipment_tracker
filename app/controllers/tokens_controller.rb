class TokensController < ApplicationController
  def index
    @token = Token.new
    @tokens = Token.all
  end

  def create
    Token.create(source: params[:token][:source])

    redirect_to tokens_path
  end
end
