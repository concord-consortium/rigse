class Portal::ResourcePage < ActiveRecord::Base
  set_table_name :portal_resource_pages
  include Publishable
  
  attr_accessor :new_attached_files
  
  belongs_to :user
  has_many :attached_files, :as => :attachable, :dependent => :destroy
  has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"
    
  validates_presence_of :user_id, :name, :publication_status
  
  named_scope :by_user, proc { |u| { :conditions => {:user_id => u.nil? ? u : u.id} } }
  named_scope :with_status, proc { |s| { :conditions => { :publication_status => s } } }
  named_scope :public_status, :conditions => { :publication_status => 'public' }
  named_scope :private_status, :conditions => { :publication_status => 'private' }
  named_scope :draft_status, :conditions => { :publication_status => 'draft' }
  named_scope :published_or_by_user, proc { |u| 
    { :conditions => ["portal_resource_pages.user_id = ? OR portal_resource_pages.publication_status = ?", u.nil? ? u : u.id, "published"] }
  }
  
  self.extend SearchableModel
  @@searchable_attributes = %w{name description publication_status}
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end
    
    def display_name
      "Resource Page"
    end
  end
  
  
  def editable_by?(other_user)
    self.user == other_user || other_user.has_role?("admin")
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
  
end
