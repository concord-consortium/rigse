class URLResolver
  include ActionController::UrlWriter
  
  def getUrl(method, options)
    eval("#{method}(options)")
  end
end