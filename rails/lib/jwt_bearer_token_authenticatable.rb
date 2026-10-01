module JwtBearerTokenAuthenticatable
  class BearerToken < Devise::Strategies::Authenticatable

    def valid?
      has_jwt_bearer_token? && SignedJwt.portal_token?(jwt_token_value)
    end

    def authenticate!
      decoded_token = SignedJwt.decode_portal_token(jwt_token_value)
      unless decoded_token && decoded_token[:data].key?("uid")
        Rails.logger.warn("JwtBearerToken: token decode failed or missing uid")
        return fail!(:invalid_token)
      end
      unless PortalBearer.scheme_accepts?(request.headers['Authorization'], decoded_token[:header])
        Rails.logger.warn("JwtBearerToken: an access token sent as Bearer/JWT")
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
      data = decoded_token[:data]
      TokenScope.apply!(data)
      @stateless = TokenScope.scoped? || SignedJwt.access_token_header?(decoded_token[:header])
      request.env['portal.minted_via_oidc_client_id'] = data['minted_via_oidc_client_id']
      request.env['portal.minted_for']                = data['minted_for']
      success!(user)
    rescue JWT::ExpiredSignature => e
      Rails.logger.warn("JwtBearerToken: token expired - #{e.message}")
      fail!(:token_expired)
    rescue SignedJwt::Error => e
      Rails.logger.warn("JwtBearerToken: decode error - #{e.message}")
      fail!(:invalid_token)
    end

    # A scoped token or an access token never becomes a Rails session, which would outlive it
    # and keep none of its limits. Warden reads this after authenticate!, so it decides per token.
    def store?
      !@stateless && super
    end

    protected

    def has_jwt_bearer_token?
      jwt_token_value.present?
    end

    # Extracts the JWT from the Authorization header, through the parser the capability
    # check shares: the explicit Bearer/JWT scheme, or plain Bearer when the token looks
    # like a JWT (contains dots).
    def jwt_token_value
      header = request.headers['Authorization'] || ''
      token = PortalBearer.raw_token(header)
      token if token && (PortalBearer.legacy_scheme?(header) || SignedJwt.probably_jwt?(token))
    end

  end
end

Warden::Strategies.add(:jwt_bearer_token_authenticatable, JwtBearerTokenAuthenticatable::BearerToken)
Devise.add_module :jwt_bearer_token_authenticatable, :strategy => true
