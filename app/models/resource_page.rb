class ResourcePage < ActiveRecord::Base
  set_table_name :resource_pages
  include Publishable
  include Changeable

  attr_accessor :new_attached_files

  belongs_to :user
  has_many :attached_files, :as => :attachable, :dependent => :destroy
  has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"
  has_many :student_views, :as => :viewable

  validates_presence_of :user_id, :name, :publication_status

  named_scope :published, :conditions => { :publication_status => 'published' }
  named_scope :private_status, :conditions => { :publication_status => 'private' }
  named_scope :draft_status, :conditions => { :publication_status => 'draft' }
  named_scope :by_user, proc { |u| { :conditions => {:user_id => u.id} } }
  named_scope :with_status, proc { |s| { :conditions => { :publication_status => s } } }
  named_scope :published_or_by_user, proc { |u|
    { :conditions => ["resource_pages.user_id = ? OR resource_pages.publication_status = 'published'", u.nil? ? u : u.id] }
  }
  named_scope :not_private_or_by_user, proc { |u|
    { :conditions => ["resource_pages.user_id = ? OR resource_pages.publication_status IN ('published', 'draft')", u.nil? ? u : u.id] }
  }

  named_scope :visible_to_user, proc { |u| { :conditions =>
    [ "resource_pages.publication_status = 'published' OR
      (resource_pages.publication_status = 'private' AND resource_pages.user_id = ?)", u.nil? ? u : u.id ]
  }}
  named_scope :visible_to_user_with_drafts, proc { |u| { :conditions =>
    [ "resource_pages.publication_status IN ('published', 'draft') OR
      (resource_pages.publication_status = 'private' AND resource_pages.user_id = ?)", u.nil? ? u : u.id ]
  }}
  named_scope :no_drafts, :conditions => "resource_pages.publication_status NOT IN ('draft')"

  named_scope :like, lambda { |name|
    name = "%#{name}%"
    { :conditions => ["resource_pages.name LIKE ? OR resource_pages.description LIKE ? OR resource_pages.content LIKE ?", name,name,name] }
  }

  named_scope :ordered_by, lambda { |order| { :order => order } }

  accepts_nested_attributes_for :attached_files

  acts_as_taggable_on :cohorts

  self.extend SearchableModel
  @@searchable_attributes = %w{name description content publication_status}
  class <<self
    def can_be_created_by?(user)
      user.has_role?('admin', 'manager', 'researcher', 'author') || user.portal_teacher
    end

    def searchable_attributes
      @@searchable_attributes
    end

    def display_name
      "Resource Page"
    end

    def search_list(options)
      resource_pages = ResourcePage.like(options[:name])

      if options[:user] && options[:user].is_a?(User) && options[:user].has_role?('admin')
        # admin users can see all ResourcePages
        resource_pages = resource_pages.no_drafts unless options[:include_drafts]
      else
        if options[:include_drafts]
          # published, draft, and private by user
          resource_pages = resource_pages.visible_to_user_with_drafts(options[:user])
        else
          # published and private by user
          resource_pages = resource_pages.visible_to_user(options[:user])
        end
      end

      if options[:portal_clazz] || (options[:portal_clazz_id] && options[:portal_clazz_id].to_i > 0)
        portal_clazz =  Portal::Clazz.find(options[:portal_clazz_id].to_i)
        resource_pages = resource_pages - portal_clazz.offerings.map { |o| o.runnable }
      end

      unless options[:sort_order].blank?
        resource_pages = resource_pages.ordered_by(options[:sort_order])
      end

      if options[:paginate]
        resource_pages = resource_pages.paginate(:page => options[:page] || 1, :per_page => options[:per_page] || 20)
      end

      resource_pages
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
end
