module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
  end

  def require_authentication
    unauthenticated_strategy unless authenticated?
  end

  def authenticated?
    omniauth_uid || current_user
  end

  def unauthenticated_strategy
    redirect_to login_url
  end

  def current_user
    setup_current_user && OpenStruct.new(setup_current_user)
  end

  def setup_current_user
    session[:current_user] ||= omniauth_info
  end

  def omniauth_info
    request.env.fetch('omniauth.auth', {})['info'].present? &&
      request.env.fetch('omniauth.auth', {})['info']
  end

  def omniauth_uid
    request.env.fetch('omniauth.auth', {})['uid']
  end

  def teardown_current_user
    session[:current_user] = nil
  end

  def login_url
    Rails.configuration.login_url
  end
end
