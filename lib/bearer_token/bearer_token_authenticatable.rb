module BearerTokenAuthenticatable
  class BearerToken < Devise::Strategies::Authenticatable

    def valid?
      !(token_value.nil?)
    end

    def authenticate!
      resource = mapping.to.find_for_token_authentication(mapping.to.token_authentication_key => token_value)
      return fail(:invalid_token) unless resource

      if validate(resource)
        resource.after_token_authentication
        success!(resource)
      end
    end

    private

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
