require 'google_oidc_verifier'

module OidcBearerTokenAuthenticatable
  class BearerToken < Devise::Strategies::Authenticatable

    def valid?
      token = oidc_token_value
      return false unless token.present?

      # Peek at unverified payload to check issuer is Google
      unverified = begin
        JWT.decode(token, nil, false).first
      rescue JWT::DecodeError => e
        # Token looked like it should be handled by this strategy (Bearer + dots)
        # but failed to parse — worth logging since it's unexpected
        Rails.logger.warn("OidcBearer: valid? JWT decode failed: #{e.message}")
        nil
      end

      return false unless unverified

      issuer = unverified['iss']
      is_google = GoogleOidcVerifier::VALID_ISSUERS.include?(issuer)
      Rails.logger.debug("OidcBearer: valid? issuer=#{sanitize_log(issuer)} is_google=#{is_google}")
      is_google
    end

    def authenticate!
      token = oidc_token_value

      payload = GoogleOidcVerifier.verify(token)

      oidc_client = Admin::OidcClient.find_by(sub: payload['sub'])
      unless oidc_client
        Rails.logger.warn("OidcBearer: authenticate! no OidcClient found for sub=#{payload['sub']} email=#{payload['email']}")
        return fail(:invalid_token)
      end

      unless oidc_client.active?
        Rails.logger.warn("OidcBearer: authenticate! inactive client=#{oidc_client.name} (id=#{oidc_client.id})")
        return fail(:invalid_token)
      end

      request.env['portal.auth_strategy'] = 'oidc_bearer_token'
      request.env['portal.auth_client'] = oidc_client.name
      request.env['portal.auth_details'] = { sub: payload['sub'], email: payload['email'], aud: payload['aud'] }
      success!(oidc_client.user)
    rescue GoogleOidcVerifier::Error => e
      Rails.logger.warn("OidcBearer: authenticate! verification failed - #{e.message}")
      fail(:invalid_token)
    end

    private

    def sanitize_log(value)
      str = value.to_s[0, 100]
      str.gsub(/[\r\n]/, ' ')
    end

    def oidc_token_value
      header = request.headers['Authorization'] || ''
      # Must NOT match Bearer/JWT — those go to jwt_bearer_token_authenticatable
      return nil if header =~ /^Bearer\/JWT/i
      # Only match standard Bearer scheme with JWT-shaped token (has dots)
      if header =~ /^Bearer ([^\s]+)$/i
        token = $1
        token.include?('.') ? token : nil
      end
    end

  end
end

Warden::Strategies.add(:oidc_bearer_token_authenticatable, OidcBearerTokenAuthenticatable::BearerToken)
Devise.add_module :oidc_bearer_token_authenticatable, :strategy => true
