module JwtBearerTokenAuthenticatable
  class BearerToken < Devise::Strategies::Authenticatable

    def valid?
      has_jwt_bearer_token?()
    end

    def authenticate!
      decoded_token = decode_token
      unless decoded_token && decoded_token[:data].has_key?("uid")
        Rails.logger.warn("JwtBearerToken: token decode failed or missing uid")
        return fail!
      end
      user = User.find_by_id(decoded_token[:data]["uid"])
      unless user
        Rails.logger.warn(
          "JwtBearerToken: user not found for uid=#{decoded_token[:data]['uid']}"
        )
        return fail!
      end
      request.env['portal.auth_strategy'] = 'jwt_bearer_token'
      success!(user)
    end

    protected

    def decode_token
      return nil unless has_jwt_bearer_token?()
      token = jwt_token_value
      SignedJwt::decode_portal_token(token)
    rescue => e
      Rails.logger.warn("JwtBearerToken: decode error - #{e.message}")
      nil
    end

    def has_jwt_bearer_token?
      jwt_token_value.present?
    end

    # Extracts the JWT from the Authorization header. Matches both the
    # explicit Bearer/JWT scheme and plain Bearer when the token looks
    # like a JWT (contains dots).
    def jwt_token_value
      header = request.headers['Authorization'] || ''
      if header =~ /^Bearer\/JWT (.+)$/i
        $1
      elsif header =~ /^Bearer (.+)$/i && SignedJwt.probably_jwt?($1)
        $1
      end
    end

  end
end

Warden::Strategies.add(:jwt_bearer_token_authenticatable, JwtBearerTokenAuthenticatable::BearerToken)
Devise.add_module :jwt_bearer_token_authenticatable, :strategy => true
