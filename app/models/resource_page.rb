class ResourcePage < ActiveRecord::Base
  self.table_name = :resource_pages
  include Publishable
  include Changeable

  attr_accessor :new_attached_files

  belongs_to :user
  has_many :attached_files, :as => :attachable, :dependent => :destroy
  has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"
  has_many :student_views, :dependent => :destroy, :as => :viewable

  validates_presence_of :user_id, :name, :publication_status

  scope :private_status, :conditions => { :publication_status => 'private' }
  scope :draft_status, :conditions => { :publication_status => 'draft' }
  scope :with_status, proc { |s| { :conditions => { :publication_status => s } } }

  scope :visible_to_user, proc { |u| { :conditions =>
    [ "resource_pages.publication_status = 'published' OR
      (resource_pages.publication_status = 'private' AND resource_pages.user_id = ?)", u.nil? ? u : u.id ]
  }}
  scope :visible_to_user_with_drafts, proc { |u| { :conditions =>
    [ "resource_pages.publication_status IN ('published', 'draft') OR
      (resource_pages.publication_status = 'private' AND resource_pages.user_id = ?)", u.nil? ? u : u.id ]
  }}
  scope :no_drafts, :conditions => "resource_pages.publication_status NOT IN ('draft')"

  scope :like, lambda { |name|
    name = "%#{name}%"
    { :conditions => ["resource_pages.name LIKE ? OR resource_pages.description LIKE ? OR resource_pages.content LIKE ?", name,name,name] }
  }

  accepts_nested_attributes_for :attached_files

  acts_as_taggable_on :cohorts
  include TaggableMaterial

  self.extend SearchableModel
  @@searchable_attributes = %w{name description content publication_status}
  class <<self
    def can_be_created_by?(user)
      user.has_role?('admin', 'manager', 'researcher', 'author') || (Admin::Project.default_project.teachers_can_author? && user.portal_teacher)
    end

    def searchable_attributes
      @@searchable_attributes
    end
  end

  def display_name
    res = []
    res << "[#{self.publication_status.upcase}]" if %w(draft private).include?(self.publication_status)
    res << self.name
    res.join(" ")
  end

  # Should receive a list (or single item) in the form of:
  # { 'name' => '...', 'attachment' => 'File...' }
  def new_attached_files=(item_or_list)
    item_or_list = [ item_or_list ] unless item_or_list.is_a? Array
    item_or_list.each do |item|
      next if item.blank? || item['name'].blank? || item['attachment'].blank?
      self.attached_files << AttachedFile.new({:user_id => self.user_id}.merge(item))
    end
  end

  def has_attached_files?
    !self.attached_files.blank?
  end

  def print_listing
    [{ "#{self.name}" => self }]
  end

  def student_views_count
    # with the mysql2 adapter this sum('count') returns a float for some reason
    student_views.sum('count').to_i
  end
  
  def run_format
    nil
  end

  # if a user has created a resource_page they are now an author so they should see
  # authoring affordances. This approach seems confusing, but it is the same approach is used
  # by investigations.
  after_save :add_author_role_to_user

  def add_author_role_to_user
    if self.user
      self.user.add_role('author')
    end
  end

end
