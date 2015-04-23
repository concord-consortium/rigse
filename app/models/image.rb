class Image < ActiveRecord::Base
  UseUploadedByInAttribution = false

  attr_accessor :is_reprocessing

  belongs_to :user
  belongs_to :license,
    :class_name  => 'CommonsLicense',
    :primary_key => 'code',
    :foreign_key => 'license_code'

  # resize the attributed version to fit within the default-sized activity window
  has_attached_file :image,
    :styles => {:thumb => {:geometry => "50x50#"},
    :attributed => {:geometry => "650x400>"}},
    :processors => [:attributor_append, :thumbnail]

  before_create :check_image_presence
  before_save :check_image_presence
  before_update :redo_watermark
  after_update :clear_flags
  before_image_post_process :clean_image_filename
  after_post_process :save_image_dimensions

  validates_presence_of :user_id, :name, :publication_status

  scope :published, :conditions => { :publication_status => 'published' }
  scope :private_status, :conditions => { :publication_status => 'private' }
  scope :draft_status, :conditions => { :publication_status => 'draft' }
  scope :by_user, proc { |u| { :conditions => {:user_id => u.id} } }
  scope :with_status, proc { |s| { :conditions => { :publication_status => s } } }
  scope :not_private, { :conditions => "#{self.table_name}.publication_status IN ('published', 'draft')" }

  scope :visible_to_user, proc { |u| { :conditions =>
    [ "#{self.table_name}.publication_status = 'published' OR
      (#{self.table_name}.publication_status = 'draft' AND #{self.table_name}.user_id = ?) OR
      (#{self.table_name}.publication_status = 'private' AND #{self.table_name}.user_id = ?)", u.nil? ? u : u.id , u.nil? ? u : u.id ]
  }}
  scope :visible_to_user_with_drafts, proc { |u| { :conditions =>
    [ "#{self.table_name}.publication_status IN ('published', 'draft') OR
      (#{self.table_name}.publication_status = 'private' AND #{self.table_name}.user_id = ?)", u.nil? ? u : u.id ]
  }}
  scope :no_drafts, :conditions => "#{self.table_name}.publication_status NOT IN ('draft')"

  scope :like, lambda { |name|
    name = "%#{name}%"
    { :conditions => ["#{self.table_name}.name LIKE ? OR #{self.table_name}.attribution LIKE ?", name,name] }
  }

  scope :ordered_by, lambda { |order| { :order => order } }

  include Changeable
  include Publishable

  self.extend SearchableModel
  @@searchable_attributes = %w{name attribution}
  class <<self
    def can_be_created_by?(user)
      user.has_role?('admin', 'manager', 'researcher', 'author') || (Admin::Settings.default_settings.teachers_can_author? && user.portal_teacher)
    end

    def searchable_attributes
      @@searchable_attributes
    end

    def search_list(options)
      name = options[:name]
      name_matches = Image.like(name)
      images = options[:only_current_users] ? name_matches.by_user(options[:user]) : name_matches.visible_to_user(options[:user])

      unless options[:sort_order].blank?
        images = images.ordered_by(options[:sort_order])
      end

      if options[:paginate]
        images = images.paginate(:page => options[:page] || 1, :per_page => options[:per_page] || 20)
      end

      images
    end
  end

  def check_image_presence
    if self.image_file_name.blank?
      self.errors.add(:image, :blank)
      return false
    end
    return true
  end

  def display_name
    res = []
    res << "[#{self.publication_status.upcase}]" if %w(draft private).include?(self.publication_status)
    res << self.name
    res.join(" ")
  end

  def clean_image_filename
    new_filename = image_file_name.downcase.gsub(/[^a-z0-9\-\_\.]+/, '-').gsub(/[-]+/,'-')
    self.image.instance_write(:file_name, new_filename)
  end

  def save_image_dimensions
    geo = Paperclip::Geometry.from_file(image.queued_for_write[:attributed])
    self.width  = geo.width.round
    self.height = geo.height.round
  end

  # when the attribution changes
  # we need to trigger this, but it can recurse without flag
  def redo_watermark
    return true if self.is_reprocessing
    self.is_reprocessing = true
    if attribution_changed?
      if self.image
        self.image.reprocess!
      end
    end
  end

  def clear_flags
    self.is_reprocessing = false
  end

  def dimensions
    "%{width}x%{height}" % {
      :width  => self.width,
      :height => self.height
    }
  end

  def image_size
    size = 0
    begin
        size   = self.image.size || 0
    rescue ::Exception => e
      Rails.logger.warn("Unexpected error sizing image in models/image.rb:  #{e}")
    end
    size
  end

  # NOTE: user_id and user are nil here. (??)
  def uploaded_by_attribution
    if (self.user && UseUploadedByInAttribution)
      return "Uploaded by: #{self.user.login}"
    end
    return ""
  end

end
