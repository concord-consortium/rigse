module JwtBearerTokenAuthenticatable
  class BearerToken < Devise::Strategies::Authenticatable

    def valid?
      return false unless has_jwt_bearer_token?
      # Peek at unverified payload to check ownership
      unverified = JWT.decode(jwt_token_value, nil, false).first rescue nil
      return false unless unverified
      # Ours if iss matches, or legacy token with uid but no iss
      unverified['iss'] == APP_CONFIG[:site_url] || (unverified.key?('uid') && !unverified.key?('iss'))
    end

    def authenticate!
      decoded_token = decode_token
      unless decoded_token && decoded_token[:data].key?("uid")
        Rails.logger.warn("JwtBearerToken: token decode failed or missing uid")
        return fail!(:invalid_token)
      end
      user = User.find_by_id(decoded_token[:data]["uid"])
      unless user
        Rails.logger.warn(
          "JwtBearerToken: user not found for uid=#{decoded_token[:data]['uid']}"
        )
        return fail!(:invalid_token)
      end
      request.env['portal.auth_strategy'] = 'jwt_bearer_token'
      success!(user)
    rescue JWT::ExpiredSignature => e
      Rails.logger.warn("JwtBearerToken: token expired - #{e.message}")
      fail!(:token_expired)
    rescue SignedJwt::Error => e
      Rails.logger.warn("JwtBearerToken: decode error - #{e.message}")
      fail!(:invalid_token)
    end

    protected

    def decode_token
      return nil unless has_jwt_bearer_token?
      token = jwt_token_value
      decoded = JWT.decode(token, SignedJwt.send(:hmac_secret), true, { algorithm: SignedJwt.send(:hmac_algorithm) })
      { data: decoded[0], header: decoded[1] }
    rescue JWT::ExpiredSignature
      raise
    rescue StandardError => e
      raise SignedJwt::Error.new(e.message)
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
