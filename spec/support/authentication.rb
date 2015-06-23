module Support
  module Authentication
    def logged_in(uid:, info: {})
      request.env['omniauth.auth'] = {
        'uid'      => uid,
        'info'     => info,
        'provider' => :test,
      }
    end

    def logged_out
      request.env.delete('omniauth.auth')
    end
  end
end
