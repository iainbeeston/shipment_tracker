module SessionsHelper
  def current_user
    OpenStruct.new(session[:current_user])
  end

  def login_url
    ENV.fetch(
      'AUTH_LOGIN_URL',
      'https://fundingcircle.auth0.com/authorize?response_type=code&scope=openid%20profile'\
      "&client_id=#{ENV['AUTH0_CLIENT_ID']}"\
      "&redirect_uri=#{request.protocol}#{request.host_with_port}"\
      "/auth/auth0/callback&connection=#{Rails.application.config.x.auth0_connection}",
    )
  end
end
