module Rack
  class ConfigSessionCookies

    PATH_INFO    = 'PATH_INFO'.freeze    unless defined?(PATH_INFO)
    QUERY_STRING = 'QUERY_STRING'.freeze unless defined?(QUERY_STRING)
    HTTP_COOKIE  = 'HTTP_COOKIE'.freeze  unless defined?(HTTP_COOKIE)
    SEMI_COLON = ';'
    CONFIG_REGEX = /.*\.config$/
    JNLP_REGEX = /.*\.jnlp$/
    
    def initialize(app)
      @app = app
    end

    # this is approach is to make testing easier
    def session_key
      @session_key ||= Rails.application.config.session_options[:key]
    end

    # Subvert the cookies_only=true session policy for requests ending in ".config"
    # If we are requesting a config file for a Java/OTrunk instance
    #   And there is a QUERY_STRING header set
    # Then either:
    #   Add the QUERY_STRING to the HTTP_COOKIE if an HTTP_COOKIE exists
    #   Or create an HTTP_COOKIE header with the contents of the QUERY_STRING header
    def call(env)
      path_info = env[PATH_INFO]
      if path_info[CONFIG_REGEX] || path_info[JNLP_REGEX]
        if (query_string = env[QUERY_STRING]) && session_param = query_string[/#{session_key}=[^&]*/]
          if (cookie = env[HTTP_COOKIE]).blank?
            env[HTTP_COOKIE] = session_param
          else
            if cookie[/#{session_key}=/]
              cookie[/#{session_key}=[^;]*/] = session_param
            else
              cookie << SEMI_COLON + session_param
            end
          end
        end
      end
      @app.call(env)
    end

  end
end
