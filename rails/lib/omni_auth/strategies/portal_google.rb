module OmniAuth
  module Strategies
    class PortalGoogle < OmniAuth::Strategies::GoogleOauth2
      def authorize_params
        params = super
        state = params['state'] ? [params['state']] : []
        if request.params['after_sign_in_path'].present?
          state << "after_sign_in_path=#{request.params['after_sign_in_path']}"
        end

        # it is possible there won't be any state if no request param is set
        # and the state hasn't been set by our parent
        # this code was written with omniauth-google-oauth2 version 0.2.2
        # this older version doesn't automaticaly create a random string for the state
        # newer versions of omniauth-oauth2 and omniauth-google-oauth2 do automatically
        # create a random string for the state
        if state.present?
          session['omniauth.state'] = params[:state] = state.join(' ')
        end

        params
      end
    end
  end
end
