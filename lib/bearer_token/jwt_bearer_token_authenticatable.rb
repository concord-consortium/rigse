module JwtBearerTokenAuthenticatable
  class BearerToken < Devise::Strategies::Authenticatable

    def valid?
      has_jwt_bearer_token?()
    end

    def authenticate!
      decoded_token = decode_token
      return fail! unless decoded_token && decoded_token[:data].has_key?("uid")
      success! User.find_by_id(decoded_token[:data]["uid"])
    end

    protected

    def decode_token
      return nil unless has_jwt_bearer_token?()
      strategy, token = get_strategy_and_token()
      SignedJWT::decode_portal_token(token) rescue nil
    end

    def has_jwt_bearer_token?
      strategy, token = get_strategy_and_token()
      strategy.downcase == 'bearer/jwt'  # use bearer/jwt to distingush from client bearer tokens
    end

    def get_strategy_and_token
      strategy, token = (request.headers['Authorization'] || '').split(' ')
      [(strategy || ''), (token || '')]
    end

  end
end

Warden::Strategies.add(:jwt_bearer_token_authenticatable, JwtBearerTokenAuthenticatable::BearerToken)
Devise.add_module :jwt_bearer_token_authenticatable, :strategy => true