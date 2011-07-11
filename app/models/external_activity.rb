class ExternalActivity < ActiveRecord::Base
  belongs_to :user

  has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

  has_many :teacher_notes, :as => :authored_entity
  has_many :author_notes, :as => :authored_entity

  acts_as_replicatable
  acts_as_taggable_on :cohorts

  include Changeable

  include Publishable

  self.extend SearchableModel
  @@searchable_attributes = %w{name description}

  named_scope :like, lambda { |name|
    name = "%#{name}%"
    {
     :conditions => ["#{self.table_name}.name LIKE ? OR #{self.table_name}.description LIKE ?", name,name]
    }
  }

  named_scope :published,
  {
    :conditions =>{:publication_status => "published"}
  }

  # special named scope for combining other named scopes in an OR fashion
  # FIXME This is probably terribly inefficient
  named_scope :match_any, lambda { |scopes| {
    :conditions => "(#{scopes.map{|s| "#{self.table_name}.id IN (#{s.send(:construct_finder_sql,{:select => :id})})" }.join(" OR ")})"
  }}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    def display_name
      "External Activity"
    end

    def search_list(options)
      name = options[:name]
      if (options[:include_drafts])
        external_activities = ExternalActivity.like(name)
      else
        # external_activities = ExternalActivity.published.like(name)
        external_activities = ExternalActivity.like(name)
      end

      if t = options[:user].portal_teacher
        finders = []
        if t.cohort_list.size > 0
          finders << ExternalActivity.tagged_with(t.cohort_list, :any => true, :on => :cohorts)
        end
        # also match external activities with no tags
        finders << ExternalActivity.tagged_with(Admin::Tag.find_all_by_scope("cohorts").collect{|t| t.tag }, :exclude => true, :on => :cohorts)

        # sometimes tagged_with will return an empty hash: {}
        finders.delete({})

        if finders.size > 0
          external_activities = external_activities.match_any(finders)
        end
      end

      portal_clazz = options[:portal_clazz] || (options[:portal_clazz_id] && options[:portal_clazz_id].to_i > 0) ? Portal::Clazz.find(options[:portal_clazz_id].to_i) : nil
      if portal_clazz
        external_activities = external_activities - portal_clazz.offerings.map { |o| o.runnable }
      end

      if options[:paginate]
        external_activities = external_activities.paginate(:page => options[:page] || 1, :per_page => options[:per_page] || 20)
      else
        external_activities
      end
    end

  end

  ##
  ## Hackish stub: Noah Paessel
  ##
  def offerings
    []
  end

  #def self.display_name
    #'Activity'
  #end

  def left_nav_panel_width
    300
  end

  def print_listing
    listing = []
  end
  
  def run_format
    :run_external_html
  end
end
