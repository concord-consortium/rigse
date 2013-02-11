class Image < ActiveRecord::Base
  belongs_to :user
  # resize the attributed version to fit within the default-sized activity window
  has_attached_file :image,
    :styles => {:thumb => {:geometry => "50x50#"},
    :attributed => {:geometry => "650x400>"}},
    :processors => [:attributor_append, :thumbnail]

  before_create :check_image_presence
  before_save :check_image_presence
  before_image_post_process :clean_image_filename

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
      user.has_role?('admin', 'manager', 'researcher', 'author') || (Admin::Project.default_project.teachers_can_author? && user.portal_teacher)
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
    unless self.image_file_name
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

  class ImageDimension
    FormatString = "%{width}x%{height} (%{size})"

    def initialize(image, style= :original)
      @image = image
      @style = @style
      width = height = size = 0
      begin
        dims   = Paperclip::Geometry.from_file(self.path)
        width  = dims.width  || 0
        height = dims.height || 0
        size   = image.size  || 0
      rescue ::Error => e
        Rails.log("Unexpected error in image.rb:  #{e}")
      end
      @formatted_string = FormatString % {
        :width  => width.round,
        :height => height.round,
        :size   => size.round
      }
    end

    def to_s
      @formatted_string
    end

    protected
    def path
      self.use_s3? ? @image.url(@style) : @image.path(@style)
    end

    def use_s3?
      @image.options[:storage] == :s3
    end
  end


  def image_dimensions(style=:attributed)
    @dimensions ||= begin
      ImageDimension.new(self.image,style).to_s
    end
  end

end
