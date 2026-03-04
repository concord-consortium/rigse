module BearerTokenAuthenticatable
  class BearerToken < Devise::Strategies::Authenticatable

    def valid?
      token_valid?()
    end

    def authenticate!
      return fail(:invalid_token) unless token_valid?
      resource = mapping.to.find_for_token_authentication(:access_token => token_value)
      return fail(:invalid_token) unless resource

      if validate(resource)
        resource.after_token_authentication
        request.env['portal.auth_strategy'] = 'bearer_token'
        request.env['portal.auth_client'] = @grant.client.name
        success!(resource)
      end
    end

    private
    def token_valid?
      token = token_value
      return false unless token
      @grant = AccessGrant.find_by_access_token(token)
      return false unless @grant && @grant.client
      unless @grant.client.valid_from_referer?(referer)
        Rails.logger.warn(
          "BearerToken: referer rejected" \
          " - client=#{@grant.client.name}" \
          ", referer=#{referer}" \
          ", matchers=#{@grant.client.domain_matchers}"
        )
        return false
      end
      return true
    end

    def referer
      return request.env["HTTP_REFERER"]
    end

    def token_value
      header = request.headers["Authorization"]
      if header && header =~ /^Bearer (.*)$/
        token = $1
        # Skip JWTs — they're handled by jwt_bearer_token_authenticatable.
        return nil if SignedJwt.probably_jwt?(token)
        token
      else
        nil
      end
    end

  end
end

Warden::Strategies.add(:bearer_token_authenticatable, BearerTokenAuthenticatable::BearerToken)
Devise.add_module :bearer_token_authenticatable, :strategy => true
