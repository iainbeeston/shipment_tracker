Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :auth0,
    ENV.fetch('AUTH0_CLIENT_ID', nil),
    ENV.fetch('AUTH0_CLIENT_SECRET', nil),
    'fundingcircle.auth0.com',
    callback_path: '/auth/auth0/callback',
  )
end
