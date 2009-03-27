class Image < ActiveRecord::Base
  belongs_to :user
#  has_attachment :content_type => :image, 
#                :storage => :file_system, 
#                :size => 0.kilobytes..1000.kilobytes,
#                :resize_to => '320x200>',
#                :thumbnails => { :thumb => '100x100>' }
#  validates_as_attachment

  include Changeable
  
  def self.find_all_unprocessed
    self.find(:all, :conditions => "parent_id is NULL")
  end
  
  # see: http://significantbits.wordpress.com/2007/04/06/using-attachment_fu-by-techno-weenie-to-add-image-attachment-support-to-your-rails-application/
  def source_url=(url)
    return nil if not url
    http_getter = Net::HTTP
    uri = URI.parse(url)
    response = http_getter.start(uri.host, uri.port) {|http| http.get(uri.path) }
    case response
    when Net::HTTPSuccess
      file_data = response.body
      return nil if file_data.nil? || file_data.size == 0
      self.content_type = response.content_type
      self.temp_data = file_data
      self.filename = uri.path.split('/')[-1]
    else
      return nil
    end
  end
end
