module SessionsHelper
  def current_user
    OpenStruct.new(session[:current_user])
  end

  def login_url
    ENV.fetch('AUTH_LOGIN_URL', auth0_login_url)
  end

  def auth0_login_url
    auth0_domain = ENV.fetch('AUTH0_DOMAIN')
    auth0_client_id = ENV['AUTH0_CLIENT_ID']
    auth0_connection = Rails.application.config.x.auth0_connection
    redirect_uri = "#{request.protocol}#{request.host_with_port}/auth/auth0/callback"

    "https://#{auth0_domain}/authorize"\
      '?response_type=code'\
      '&scope=openid%20profile'\
      "&client_id=#{auth0_client_id}"\
      "&redirect_uri=#{redirect_uri}"\
      "&connection=#{auth0_connection}"
  end
end
