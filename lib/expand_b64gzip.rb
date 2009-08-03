require 'zlib'

#
# Ths Rack middleware is NOT functional yet ...
#
# http://railscasts.com/episodes/151-rack-middleware
# http://remi.org/2009/02/28/rack-part-3-middleware.html
#
#
class ExpandB64Gzip
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    
    if request.env['HTTP_CONTENT_ENCODING'] == 'b64gzip'
      content = Zlib::GzipReader.new(StringIO.new(B64::B64.decode(request.raw_post))).read
    else
      content = request.raw_post
    end
    digest = Digest::MD5.hexdigest(content)
    if request.env['HTTP_CONTENT_MD5'] != nil
      if digest != request.env['HTTP_CONTENT_MD5']
        raise "Bundle MD5 Mismatch"
      end
    end
  end
    
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
    
end
