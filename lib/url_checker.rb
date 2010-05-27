require 'net/http'
require 'uri'

class UrlChecker
  
  def self.valid?(url, opts={})
    options = {
      :max_size => 0,
      :do_head => true
    }  
    options.merge!(opts)
    valid = false
    begin
      uri = URI.parse(url)
      if options[:do_head]
        response = nil
        Net::HTTP.start(uri.host,uri.port) do |http|
          response =http.head(uri.path)
        end
        if (response && response.class == Net::HTTPOK &&
           (options[:max_size] == 0 || response.content_length < options[:max_size]))
              valid = true
        end
      else
        valid = true
      end
    rescue Exception => error
      false
    end
    return valid
  end

end
