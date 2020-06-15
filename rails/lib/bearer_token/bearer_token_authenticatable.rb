module BearerTokenAuthenticatable
  class BearerToken < Devise::Strategies::Authenticatable

    def valid?
      token_valid?()
    end

    def authenticate!
      return fail(:invalid_token) unless token_valid?
      resource = mapping.to.find_for_token_authentication(mapping.to.token_authentication_key => token_value)
      return fail(:invalid_token) unless resource

      if validate(resource)
        resource.after_token_authentication
        success!(resource)
      end
    end

    private
    def token_valid?
      token = token_value
      return false unless token
      grant = AccessGrant.find_by_access_token(token)
      return false unless grant && grant.client
      return false unless grant.client.valid_from_referer?(referer)
      return true
    end

    def referer
      return request.env["HTTP_REFERER"]
    end

    def token_value
      header = request.headers["Authorization"]
      if header && header =~ /^Bearer (.*)$/
        $1
      else
        nil
      end
    end

  end
end

Warden::Strategies.add(:bearer_token_authenticatable, BearerTokenAuthenticatable::BearerToken)
Devise.add_module :bearer_token_authenticatable, :strategy => true
