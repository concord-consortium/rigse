class URLResolver
  include Rails.application.routes.url_helpers
  
  def getUrl(method, options = {})
    options[:script_name] ||= ApplicationController.config.relative_url_root
    eval("#{method}(options)")
  end

  def self.getUrl(method, options = {})
    @resolver ||= self.new
    @resolver.getUrl(method, options)
  end
end
