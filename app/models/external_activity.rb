require 'uri'
class ExternalActivity < ActiveRecord::Base
  belongs_to :user

  has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

  has_many :teacher_notes, :dependent => :destroy, :as => :authored_entity
  has_many :author_notes, :dependent => :destroy, :as => :authored_entity

  belongs_to :template, :polymorphic => true

  acts_as_replicatable
  acts_as_taggable_on :cohorts
  include TaggableMaterial

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

  class <<self
    def searchable_attributes
      @@searchable_attributes
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
