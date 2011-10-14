module Rack
  class ConfigSessionCookies

    PATH_INFO    = 'PATH_INFO'.freeze    unless defined?(PATH_INFO)
    QUERY_STRING = 'QUERY_STRING'.freeze unless defined?(QUERY_STRING)
    HTTP_COOKIE  = 'HTTP_COOKIE'.freeze  unless defined?(HTTP_COOKIE)
    SEMI_COLON = ';'
    
    def initialize(app)
      @app = app
    end

    # Subvert the cookies_only=true session policy for requests ending in ".config"
    # If we are requesting a config file for a Java/OTrunk instance
    #   And there is a QUERY_STRING header set
    # Then either:
    #   Add the QUERY_STRING to the HTTP_COOKIE if an HTTP_COOKIE exists
    #   Or create an HTTP_COOKIE header with the contents of the QUERY_STRING header
    def call(env)
      if env[PATH_INFO][/.*\.config$/]
        if env[QUERY_STRING]
          if env[HTTP_COOKIE]
            env[HTTP_COOKIE] = env[HTTP_COOKIE] + SEMI_COLON + env[QUERY_STRING]
          else
            env[HTTP_COOKIE] = env[QUERY_STRING]
          end
        end
      end
      @app.call(env)
    end

  end
end
