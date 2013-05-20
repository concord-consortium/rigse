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

  scope :published, :conditions => { :publication_status => 'published' }
  scope :private_status, :conditions => { :publication_status => 'private' }
  scope :draft_status, :conditions => { :publication_status => 'draft' }
  scope :by_user, proc { |u| { :conditions => {:user_id => u.id} } }
  scope :with_status, proc { |s| { :conditions => { :publication_status => s } } }
  scope :not_private, { :conditions => "#{self.table_name}.publication_status IN ('published', 'draft')" }

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

  scope :ordered_by, lambda { |order| { :order => order } }

  # Special :match_any scope for combining other named scopes in an OR fashion
  #
  # FIXME This is probably terribly inefficient and can probably be done more
  # cleanly in the new Rails 3 ActiveRecord::Relation and Arel features.
  #
  # In addition it should probably be folded into an updated SearchableModel
  #
  # Resources:
  #   http://guides.rubyonrails.org/active_record_querying.html
  #   http://m.onkey.org/active-record-query-interface
  #   http://asciicasts.com/episodes/202-active-record-queries-in-rails-3
  #   http://erniemiller.org/2010/05/11/activerecord-relation-vs-arel/
  #   http://erniemiller.org/2010/03/28/advanced-activerecord-3-queries-with-arel/
  #
  # The basic query conditions look like this: 
  #
  #   (resource_pages.id IN () OR resource_pages.id IN ())
  #
  # An additional set of SQL constraints is generated and placed inside 
  # each IN() clause with this statement:
  #
  #   scope.select('id').to_sql
  #
  # For example this query: 
  #
  #   ResourcePage.search_list( { :name => "abc", :user => @admin_user })
  #
  # results in this sql:
  #
  #   SELECT `resource_pages`.* FROM `resource_pages` 
  #   WHERE (
  #     (
  #       resource_pages.id IN (
  #         SELECT id FROM `resource_pages` 
  #         WHERE `resource_pages`.`publication_status` = 'published' 
  #         AND (resource_pages.name LIKE '%abc%' OR resource_pages.description LIKE '%abc%' OR resource_pages.content LIKE '%abc%')
  #       ) OR resource_pages.id IN (
  #         SELECT id FROM `resource_pages` WHERE `resource_pages`.`user_id` = 22 
  #         AND (resource_pages.name LIKE '%abc%' OR resource_pages.description LIKE '%abc%' OR resource_pages.content LIKE '%abc%')
  #       )
  #     )
  #   )
  #

  scope :match_any, lambda { |scopes| 
    table_name_dot_id = "#{self.table_name}.id"
    conditions = "(#{scopes.map { |scope| "#{table_name_dot_id} IN (#{scope.select(table_name_dot_id).to_sql})" }.join(" OR ")})"
    where(conditions)
  }

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
