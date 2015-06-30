module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_login
  end

  def require_login
    logged_out_strategy unless logged_in?
  end

  def logged_in?
    request.env.fetch('omniauth.auth', {})['uid'] || session[:current_user]
  end

  def logged_out_strategy
    redirect_to login_url
  end

  def current_user
    OpenStruct.new(setup_current_user)
  end

  def setup_current_user
    session[:current_user] ||= request.env.fetch('omniauth.auth', {})['info']
  end

  def teardown_current_user
    session[:current_user] = nil
  end

  def login_url
    Rails.configuration.login_url
  end
end
