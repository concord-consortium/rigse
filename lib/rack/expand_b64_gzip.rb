require 'zlib'

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
        post_body = ::Zlib::GzipReader.new(StringIO.new(B64.decode(env[POST_BODY].read)))
        env[CONTENT_LENGTH] = post_body.read.length
        post_body.rewind if post_body.respond_to?(:rewind)
        env[POST_BODY] = post_body
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
    
  # req = Rack::Request.new(env)
  # body = req.body
  # scheme = req.scheme
  # script_name = req.script_name
  # path_info = req.path_info
  # port = req.port
  # request_method = req.request_method
  # query_string = req.query_string
  # content_length = req.content_length
  # content_type = req.content_type
  # content_encoding = req.content_encoding
  # session = req.session
  # session_options = req.session_options
  
  # status, headers, response = @app.call(env)
  # 
  # if request.env['HTTP_CONTENT_ENCODING'] == 'b64gzip'
  #   content = Zlib::GzipReader.new(StringIO.new(B64::B64.decode(request.raw_post))).read
  # else
  #   content = request.raw_post
  # end
  # digest = Digest::MD5.hexdigest(content)
  # if request.env['HTTP_CONTENT_MD5'] != nil
  #   if digest != request.env['HTTP_CONTENT_MD5']
  #     raise "Bundle MD5 Mismatch"
  #   end
  # end
  
  # http://pastie.org/404695
  # def call(env)
  #   dup._call(env)
  # end
  # 
  # def _call(env)
  #   @start = Time.now
  #   @status, @headers, @response = @app.call(env)
  #   @stop = Time.now
  #   [@status, @headers, self]
  # end
  # 
  # def each(&block)
  #   block.call("<!-- #{@message}: #{@stop - @start} -->\n") if @headers["Content-Type"].include? "text/html"
  #   @response.each(&block)
  # end
