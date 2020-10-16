Devise::TokenAuthenticatable.setup do |config|
  # set the authentication key name used by this module,
  # defaults to :auth_token
  config.token_authentication_key = "access_token"

  # POSSIBLE OPTIONS - using defaults for now

  # enable reset of the authentication token before the model is saved,
  # defaults to false
  # config.should_reset_authentication_token = true

  # enables the setting of the authentication token - if not already - before the model is saved,
  # defaults to false
  # config.should_ensure_authentication_token = true
end