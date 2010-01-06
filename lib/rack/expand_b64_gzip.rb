#
# Rack middleware to decode and expand posted content 
# with a content-encoding of: 'b64gzip'
#
# http://railscasts.com/episodes/151-rack-middleware
# http://remi.org/2009/02/28/rack-part-3-middleware.html
#
#

require "zlib"
require "stringio"
require 'rack/utils'

module Rack
  class ExpandB64Gzip
    
    # supported content encoding
    B64_GZIP_ENCODED = 'b64gzip'.freeze
    HTTP_CONTENT_ENCODING = 'HTTP_CONTENT_ENCODING'.freeze
    CONTENT_LENGTH = 'CONTENT_LENGTH'.freeze
    
    POST_BODY = 'rack.input'.freeze
    
    def initialize(app)
      @app = app
    end

    def call(env)
      if env[HTTP_CONTENT_ENCODING] == B64_GZIP_ENCODED
        post_body = ::Zlib::GzipReader.new(StringIO.new(B64.decode(env[POST_BODY].read))).read
        env[CONTENT_LENGTH] = post_body.length
        env[POST_BODY] = StringIO.new(post_body)
        # headers.delete(Const::CONTENT_ENCODING)
      end
      @app.call(env)
    end

    class B64
      def self.folding_encode(str, eol = "\n", limit = 60)
        [str].pack('m')
      end

      def self.encode(str)
        [str].pack('m').tr( "\r\n", '')
      end

      def self.decode(str, strict = false)
        str.unpack('m').first
      end
    end
  end
end
