require 'uri'
class ExternalActivity < ActiveRecord::Base

  # see https://github.com/sunspot/sunspot/blob/master/README.md
  searchable do
    text :name
    text :description
    boolean :is_official
    boolean :published do |ea|
      ea.publication_status == 'published'
    end

    integer :offerings_count
    time    :updated_at
    time    :created_at
  end

  belongs_to :user

  has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

  has_many :teacher_notes, :dependent => :destroy, :as => :authored_entity
  has_many :author_notes, :dependent => :destroy, :as => :authored_entity

  belongs_to :template, :polymorphic => true

  acts_as_replicatable
  acts_as_taggable_on :cohorts

  include Changeable

  include Publishable

  self.extend SearchableModel
  @@searchable_attributes = %w{name description is_official}

  scope :like, lambda { |name|
    name = "%#{name}%"
    {
     :conditions => ["#{self.table_name}.name LIKE ? OR #{self.table_name}.description LIKE ?", name,name]
    }
  }

  scope :published,
  {
    :conditions =>{:publication_status => "published"}
  }

  scope :assigned, where('offerings_count > 0')

  scope :not_private,
  {
    :conditions => "#{self.table_name}.publication_status IN ('published', 'draft')"
  }

  scope :by_user, proc { |u| { :conditions => {:user_id => u.id} } }

  scope :ordered_by, lambda { |order| { :order => order } }
  # FIXME: See comments in app/models/resource_page.rb
  scope :match_any, lambda { |scopes|
    table_name_dot_id = "#{self.table_name}.id"
    conditions = "(#{scopes.map { |scope| "#{table_name_dot_id} IN (#{scope.select(table_name_dot_id).to_sql})" }.join(" OR ")})"
    where(conditions)
  }

  scope :official, where(:is_official => true)
  scope :contributed, where(:is_official => false)

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end


    def search_list(options)
      name = options[:name]
      name_matches = ExternalActivity.like(name)
      is_visible = options[:include_drafts] ? name_matches.not_private : name_matches.published
      sort_order = options[:sort_order] || "name ASC"
      external_activities = nil

      if options[:user]
        by_user = name_matches.by_user(options[:user]) if options[:user]
        if (t = options[:user].portal_teacher) && ! options[:user].has_role?('admin')
          # if we're not an admin, filter by tags as well
          matches_tags = nil
          has_no_tags = nil
          available_cohorts = Admin::Tag.find_all_by_scope("cohorts")
          if available_cohorts.size > 0
            has_no_tags = ExternalActivity.tagged_with(available_cohorts.collect{|c| c.tag }, :exclude => true, :on => :cohorts)
          end
          if t.cohort_list.size > 0
            # and match everything with the correct tags
            matches_tags = ExternalActivity.tagged_with(t.cohort_list, :any => true, :on => :cohorts)
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
        external_activities = ExternalActivity.match_any([is_visible, by_user])
      else
        external_activities = is_visible
      end

      if !options[:include_contributed]
        # If param is included, we want *all*; if not, only the Concord ones.
        external_activities = external_activities.official
      end

      portal_clazz = options[:portal_clazz] || (options[:portal_clazz_id] && options[:portal_clazz_id].to_i > 0) ? Portal::Clazz.find(options[:portal_clazz_id].to_i) : nil
      if portal_clazz
        external_activities = external_activities - portal_clazz.offerings.map { |o| o.runnable }
      end
      if external_activities.respond_to? :ordered_by
        external_activities = external_activities.ordered_by(sort_order)
      end
      if options[:paginate]
        external_activities = external_activities.paginate(:page => options[:page] || 1, :per_page => options[:per_page] || 20)
      else
        external_activities
      end
    end

  end

  def url(learner = nil)
    uri = URI.parse(read_attribute(:url))
    if learner
      append_query(uri, "learner=#{learner.id}") if append_learner_id_to_url
      append_query(uri, "c=#{learner.user.id}") if append_survey_monkey_uid
    end
    return uri.to_sc
  end

  # methods to mimic Activity
  def teacher_only
    false
  end

  def teacher_only?
    false
  end

  def parent
    nil
  end
  # end methods to mimic Activity

  def left_nav_panel_width
    300
  end

  def print_listing
    listing = []
  end
  
  def run_format
    :run_external_html
  end
  
  def report_format
    :run_external_html
  end

  private

  def append_query(uri, query_str)
    queries = [uri.query, query_str]
    uri.query = queries.compact.join("&")
  end
end
