class ResourcePage < ActiveRecord::Base
  set_table_name :resource_pages
  include Publishable
  include Changeable
  
  attr_accessor :new_attached_files
  
  belongs_to :user
  has_many :attached_files, :as => :attachable, :dependent => :destroy
  has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"
    
  validates_presence_of :user_id, :name, :publication_status
  
  named_scope :published, :conditions => { :publication_status => 'published' }
  named_scope :private_status, :conditions => { :publication_status => 'private' }
  named_scope :draft_status, :conditions => { :publication_status => 'draft' }
  named_scope :by_user, proc { |u| { :conditions => {:user_id => u.nil? ? u : u.id} } }
  named_scope :with_status, proc { |s| { :conditions => { :publication_status => s } } }
  named_scope :published_or_by_user, proc { |u| 
    { :conditions => ["resource_pages.user_id = ? OR resource_pages.publication_status = ?", u.nil? ? u : u.id, "published"] }
  }
  named_scope :like, lambda { |name|
    name = "%#{name}%"
    { :conditions => ["resource_pages.name LIKE ? OR resource_pages.description LIKE ?", name,name] }
  }
  
  accepts_nested_attributes_for :attached_files
  
  self.extend SearchableModel
  @@searchable_attributes = %w{name description publication_status}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    
    def display_name
      "Resource Page"
    end
    
    def search_list(options)
      resource_pages = ResourcePage.like(options[:name])

      unless options[:include_drafts]
        resource_pages = resource_pages.published
      end

      if options[:portal_clazz] || (options[:portal_clazz_id] && options[:portal_clazz_id].to_i > 0)
        portal_clazz =  Portal::Clazz.find(options[:portal_clazz_id].to_i)
        resource_pages = resource_pages - portal_clazz.offerings.map { |o| o.runnable }
      end

      if options[:paginate]
        resource_pages = resource_pages.paginate(:page => options[:page] || 1, :per_page => options[:per_page] || 20)
      end

      resource_pages
    end
  end
    
  # Should receive a list in the form of [ {:name='', :attachment=''}, ...] 
  # or just a single item: {:name='', :attachment=''}
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

end
