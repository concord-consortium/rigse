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

    # Token strategies must not serialize the acting identity into a session.
    def store?
      false
    end

    def authenticate!
      token = oidc_token_value
      payload = GoogleOidcVerifier.verify(token)

      oidc_client = Admin::OidcClient.find_by(sub: payload['sub'])
      return fail_oidc!('no OidcClient found', payload) unless oidc_client
      return fail_oidc!('inactive client', payload) unless oidc_client.active?

      stamp_common(oidc_client, payload)

      forwarded = forwarded_jwt_value

      unless oidc_client.capabilities.present? || oidc_client.requires_forwarded_jwt?
        return success_as_mapped_user!(oidc_client)
      end

      if forwarded.present?
        authenticate_forwarded_student!(oidc_client, forwarded)
      elsif oidc_client.requires_forwarded_jwt?
        fail_auth!('forwarded_token_required', "header absent for client=#{oidc_client.id}")
      else
        Rails.logger.info("OidcBearer: header-absent fallback to mapped user client=#{oidc_client.id}")
        success_as_mapped_user!(oidc_client)
      end
    rescue GoogleOidcVerifier::Error => e
      fail_auth!('oidc_token_invalid', "verification failed - #{sanitize_log(e.message)}")
    end

    private

    def authenticate_forwarded_student!(oidc_client, forwarded)
      result = ForwardedFirebaseToken.verify(forwarded)
      request.env['portal.auth_client_id']     = oidc_client.id
      request.env['portal.forwarded_student']  = true
      request.env['portal.origin_offering_id'] = result.origin_offering.id
      request.env['portal.origin_class_hash']  = result.origin_clazz.class_hash
      request.env['devise.skip_trackable']     = true
      success!(result.user)
    rescue ForwardedFirebaseToken::Invalid => e
      fail_auth!('forwarded_token_invalid', "forwarded token invalid reason=#{e.reason} client=#{oidc_client.id}")
    end

    def success_as_mapped_user!(oidc_client)
      request.env['portal.auth_client_id'] = oidc_client.id
      success!(oidc_client.user)
    end

    def stamp_common(oidc_client, payload)
      request.env['portal.auth_strategy'] = 'oidc_bearer_token'
      request.env['portal.auth_client']   = oidc_client.name
      request.env['portal.auth_details']  = { sub: payload['sub'], email: payload['email'], aud: payload['aud'] }
    end

    def fail_oidc!(msg, payload)
      Rails.logger.warn("OidcBearer: authenticate! #{msg} for sub=#{payload['sub']} email=#{payload['email']}")
      fail_auth!('oidc_token_invalid', msg)
    end

    # Stamp a machine code for ForwardedAuthGuard to render as 401 + error_code,
    # then fail (non-bang). Fail-closed is enforced by the guard keying on
    # portal.auth_error being present, not by halting the chain.
    def fail_auth!(code, log_msg)
      request.env['portal.auth_error'] = code
      Rails.logger.warn("OidcBearer: #{log_msg} (error_code=#{code})")
      fail(:invalid_token)
    end

    def forwarded_jwt_value
      request.headers['X-Portal-Student-JWT'].presence
    end

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
