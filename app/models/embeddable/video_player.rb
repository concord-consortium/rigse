class Embeddable::VideoPlayer < ActiveRecord::Base
  self.table_name = "embeddable_video_players"

  belongs_to :user
  has_many :page_elements, :as => :embeddable
  has_many :pages, :through =>:page_elements
  has_many :teacher_notes, :as => :authored_entity
  validates_presence_of :name
  validate :validate_video_url


  acts_as_replicatable

  include Changeable
  include HasImage
  self.extend SearchableModel
  
  @@searchable_attributes = %w{uuid name description }
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
  end

  default_value_for :name, "video clip of"
  default_value_for :description, "description of the video..."

  send_update_events_to :investigations
  
  
  def investigations
    invs = []
    self.pages.each do |page|
      inv = page.investigation
      invs << inv if inv
    end
  end
  

  def has_video_url?
    return false if video_url.nil?
    return false if video_url == ""
    return false if video_url =~/^\s+$/
    true
  end

  def validate_video_url  
    return unless self.has_video_url?
    return true if UrlChecker.valid?(self.video_url)
    errors.add_to_base("bad video url: #{self.video_url}")
  end

end
