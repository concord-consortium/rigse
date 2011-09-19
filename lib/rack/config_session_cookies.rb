module Rack
  class ConfigSessionCookies

    PATH_INFO    = 'PATH_INFO'.freeze    unless defined?(PATH_INFO)
    QUERY_STRING = 'QUERY_STRING'.freeze unless defined?(QUERY_STRING)
    HTTP_COOKIE  = 'HTTP_COOKIE'.freeze  unless defined?(HTTP_COOKIE)
    
    def initialize(app)
      @app = app
    end

    # Subvert the cookies_only=true session policy for requests ending in ".config"
    # If we are requesting a config file for a Java/OTrunk instance
    #   And there is no HTTP_COOKIE header set
    #   And there is a QUERY_STRING header set
    # Then create an HTTP_COOKIE header with the contents of the QUERY_STRING header
    def call(env)
      if env[PATH_INFO][/.*\.config$/]
        if !env[HTTP_COOKIE] && env[QUERY_STRING]
          env[HTTP_COOKIE] = env[QUERY_STRING]
        end
      end
      @app.call(env)
    end

  end
end
