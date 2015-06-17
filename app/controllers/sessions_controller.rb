class SessionsController < ApplicationController
  skip_before_action :require_login

  def auth0_success_callback
    session[:current_user] = request.env['omniauth.auth']['info']
    flash[:info] = "Hello #{current_user.first_name || current_user.email}!"
    redirect_to root_path
  end

  def auth0_failure_callback
    render text: 'Sorry - you are not authorized to use this application.', status: 401
  end

  def destroy
    session[:current_user] = nil
    redirect_to ENV.fetch('AUTH_LOGOUT_URL', "https://#{ENV['AUTH0_DOMAIN']}/logout")
  end
end
