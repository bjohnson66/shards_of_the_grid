# OAuth Middleware
OmniAuth.config.logger = Rails.logger
OmniAuth.config.allowed_request_methods = [:get, :post]
OmniAuth.config.request_validation_phase = nil


Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'], {
    scope: 'email,profile',
    redirect_uri: 'https://murmuring-tundra-75082-54a25dd3ffd4.herokuapp.com/auth/google_oauth2/callback'
  }
end


