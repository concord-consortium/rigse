require 'net/https'
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
      uri.path = '/' if uri.path.blank?
      if options[:do_head]
        response = nil
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == "https"
          http.use_ssl = true 
          http.verify_mode= OpenSSL::SSL::VERIFY_NONE
        end
        http.start { response = http.head(uri.path) }
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

  def self.invalid?(url, opts={})
    return !self.valid?(url, opts)
  end

end
