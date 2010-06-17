module HasImage
  ##
  ## Called when a class extends this module:
  ##
  def self.included(clazz)
    clazz.class_eval do
      validate :valid_image?
      if defined? self.non_versioned_columns
        self.non_versioned_columns << 'image_url'
      end
    end
  end
  
  def has_image?
    return false if image_url.nil?
    return false if image_url == ""
    return false if image_url =~/^\s+$/
    true
  end
  
  def valid_image?
    return unless self.has_image?
    return true if UrlChecker.valid?(self.image_url)
    errors.add_to_base("bad image url: #{self.image_url}")
  end
end
