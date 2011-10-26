class URLResolver
  include Rails.application.routes.url_helpers
  
  def getUrl(method, options)
    eval("#{method}(options)")
  end
end