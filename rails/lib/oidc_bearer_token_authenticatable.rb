require 'google_oidc_verifier'

module OidcBearerTokenAuthenticatable
  class BearerToken < Devise::Strategies::Authenticatable

    def valid?
      token = oidc_token_value
      unless token.present?
        Rails.logger.info("OidcBearer: valid? token not present, skipping strategy")
        return false
      end

      # Peek at unverified payload to check issuer is Google
      unverified = begin
        JWT.decode(token, nil, false).first
      rescue JWT::DecodeError => e
        Rails.logger.info("OidcBearer: valid? JWT decode failed: #{e.message}")
        nil
      end

      unless unverified
        Rails.logger.info("OidcBearer: valid? could not decode token, skipping strategy")
        return false
      end

      issuer = unverified['iss']
      is_google = GoogleOidcVerifier::VALID_ISSUERS.include?(issuer)
      Rails.logger.info("OidcBearer: valid? issuer=#{issuer} is_google=#{is_google} sub=#{unverified['sub']} aud=#{unverified['aud']}")
      is_google
    end

    def authenticate!
      token = oidc_token_value
      Rails.logger.info("OidcBearer: authenticate! starting verification")

      payload = GoogleOidcVerifier.verify(token)
      Rails.logger.info("OidcBearer: authenticate! token verified successfully sub=#{payload['sub']} email=#{payload['email']} aud=#{payload['aud']}")

      oidc_client = Admin::OidcClient.find_by(sub: payload['sub'])
      unless oidc_client
        Rails.logger.warn("OidcBearer: authenticate! no OidcClient found for sub=#{payload['sub']} email=#{payload['email']}")
        return fail(:invalid_token)
      end

      unless oidc_client.active?
        Rails.logger.warn("OidcBearer: authenticate! inactive client=#{oidc_client.name} (id=#{oidc_client.id})")
        return fail(:invalid_token)
      end

      Rails.logger.info("OidcBearer: authenticate! success user_id=#{oidc_client.user_id} client=#{oidc_client.name}")
      request.env['portal.auth_strategy'] = 'oidc_bearer_token'
      request.env['portal.auth_client'] = oidc_client.name
      success!(oidc_client.user)
    rescue GoogleOidcVerifier::Error => e
      Rails.logger.warn("OidcBearer: authenticate! verification failed - #{e.message}")
      fail(:invalid_token)
    end

    private

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
