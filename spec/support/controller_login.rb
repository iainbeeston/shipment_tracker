module Support
  module ControllerLogin
    def login_with_omniauth(
      uid: 'xyz',
      email: 'foo@bar.com',
      first_name: 'Alice'
    )
      request.env['omniauth.auth'] = {
        'uid' => uid,
        'info' => {
          'email' => email,
          'first_name' => first_name,
        },
      }
    end
  end
end
