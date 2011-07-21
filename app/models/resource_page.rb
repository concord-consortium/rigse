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
  named_scope :not_private, { :conditions => "#{self.table_name}.publication_status IN ('published', 'draft')" }

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

  # special named scope for combining other named scopes in an OR fashion
  # FIXME This is probably terribly inefficient
  named_scope :match_any, lambda { |scopes| {
    :conditions => "(#{scopes.map{|s| "#{self.table_name}.id IN (#{s.send(:construct_finder_sql,{:select => :id})})" }.join(" OR ")})"
  }}

  accepts_nested_attributes_for :attached_files

  acts_as_taggable_on :cohorts

  self.extend SearchableModel
  @@searchable_attributes = %w{name description content publication_status}
  class <<self
    def can_be_created_by?(user)
      user.has_role?('admin', 'manager', 'researcher', 'author') || (Admin::Project.default_project.teachers_can_author? && user.portal_teacher)
    end

    def searchable_attributes
      @@searchable_attributes
    end

    def display_name
      "Resource Page"
    end

    def search_list(options)
      name = options[:name]
      name_matches = ResourcePage.like(name)
      is_visible = options[:include_drafts] ? name_matches.not_private : name_matches.published

      resource_pages = nil

      if options[:user]
        by_user = name_matches.by_user(options[:user]) if options[:user]
        if (t = options[:user].portal_teacher) && ! options[:user].has_role?('admin')
          # if we're not an admin, filter by tags as well
          matches_tags = nil
          has_no_tags = nil
          available_cohorts = Admin::Tag.find_all_by_scope("cohorts")
          if available_cohorts.size > 0
            has_no_tags = ResourcePage.tagged_with(available_cohorts.collect{|c| c.tag }, :exclude => true, :on => :cohorts)
          end

          if t.cohort_list.size > 0
            # and match everything with the correct tags
            matches_tags = ResourcePage.tagged_with(t.cohort_list, :any => true, :on => :cohorts)
          end

          # sometimes tagged_with returns an empty hash
          if has_no_tags && has_no_tags != {}
            if matches_tags && matches_tags != {}
              is_visible = is_visible.match_any([matches_tags, has_no_tags])
            else
              is_visible = is_visible.match_any([has_no_tags])
            end
          end
        end
        resource_pages = ResourcePage.match_any([is_visible, by_user])
      else
        resource_pages = is_visible
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
