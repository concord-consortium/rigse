require 'google_oidc_verifier'

module OidcBearerTokenAuthenticatable
  class BearerToken < Devise::Strategies::Authenticatable

    def valid?
      return false unless oidc_token_value.present?
      # Peek at unverified payload to check issuer is Google
      unverified = JWT.decode(oidc_token_value, nil, false).first rescue nil
      return false unless unverified
      GoogleOidcVerifier::VALID_ISSUERS.include?(unverified['iss'])
    end

    def authenticate!
      token = oidc_token_value
      payload = GoogleOidcVerifier.verify(token)

      oidc_client = Admin::OidcClient.active.find_by(sub: payload['sub'])
      unless oidc_client
        if Admin::OidcClient.find_by(sub: payload['sub'])
          Rails.logger.warn("OidcBearer: inactive client=#{Admin::OidcClient.find_by(sub: payload['sub']).name}")
        else
          Rails.logger.warn("OidcBearer: no client found sub=#{payload['sub']} email=#{payload['email']}")
        end
        return fail(:invalid_token)
      end

      request.env['portal.auth_strategy'] = 'oidc_bearer_token'
      request.env['portal.auth_client'] = oidc_client.name
      success!(oidc_client.user)
    rescue GoogleOidcVerifier::Error => e
      Rails.logger.warn("OidcBearer: verification failed - #{e.message}")
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
