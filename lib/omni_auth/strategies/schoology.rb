module OmniAuth
  module Strategies
    class Schoology < OmniAuth::Strategies::OAuth
      option :name, "schoology"

      # This is where you pass the options you would pass when
      # initializing your consumer from the OAuth gem.
      option :client_options, {
        :site => "https://api.schoology.com",
        :http_method => :get,
        :access_token_path => "/v1/oauth/access_token",
        :request_token_path => "/v1/oauth/request_token",
        :authorize_url => "https://www.schoology.com/oauth/authorize"
      }

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid { raw_info['uid'] }

      info do
        {
          :email => raw_info['primary_email']
        }
      end

      extra do
        {
          :first_name => raw_info['name_first'],
          :last_name  => raw_info['name_last']
        }
      end

      def raw_info
        return @raw_info if @raw_info
        resp = access_token.get('/v1/users/me')
        if resp.kind_of?(Net::HTTPRedirection) && resp["Location"]
          resp = access_token.get(resp["Location"])
        end

        resp_body = resp.body
        @raw_info ||= JSON.parse(resp_body)
      end
    end
  end
end
