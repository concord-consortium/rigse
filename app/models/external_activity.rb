require 'uri'
class ExternalActivity < ActiveRecord::Base

  #
  # see https://github.com/sunspot/sunspot/blob/master/README.md
  #
  searchable do
    text :name
    string :name
    text :description
    text :description_for_teacher do
      nil
    end
    text :content do
      nil
    end

    text :owner do |ea|
      ea.credits.present? ? ea.credits : ea.user && ea.user.name
    end

    integer :user_id
    boolean :published do |ea|
      ea.publication_status == 'published'
    end

    integer :offerings_count

    boolean :is_official
    boolean :is_archived

    boolean :is_assessment_item
    boolean :is_template do
      false
    end
    integer :probe_type_ids, :multiple => true do
      nil
    end
    boolean :no_probes do
      true
    end

    boolean :teacher_only do
      # Useful in Activity and Investigation; stubbed here
      false
    end
    integer :offerings_count

    time    :updated_at
    time    :created_at

    string  :grade_span do
      nil
    end
    integer :domain_id do
      nil
    end
    string  :material_type
    string  :material_properties, :multiple => true do
      material_property_list
    end
    string  :cohort_ids, :multiple => true, :references => Admin::Cohort

    string  :grade_levels, :multiple => true do
      grade_level_list
    end

    string  :subject_areas, :multiple => true do
      subject_area_list
    end

    string  :sensors, :multiple => true do
      sensor_list
    end

    integer :project_ids, :multiple => true, :references => Admin::Project

  end

  belongs_to :user
  belongs_to :external_report

  has_many :favorites, as: :favoritable

  # offerings are not deleted if they have learners, so you need to explicitly remove the learners
  # before you can delete the offering
  has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

  has_many :materials_collection_items, :dependent => :destroy, :as => :material
  has_many :materials_collections, :through => :materials_collection_items

  has_many :teacher_notes, :dependent => :destroy, :as => :authored_entity
  has_many :author_notes, :dependent => :destroy, :as => :authored_entity

  belongs_to :template, :polymorphic => true

  has_many :project_materials, :class_name => "Admin::ProjectMaterial", :as => :material, :dependent => :destroy
  has_many :projects, :class_name => "Admin::Project", :through => :project_materials

  acts_as_replicatable

  belongs_to :license,
    :class_name  => 'CommonsLicense',
    :primary_key => 'code',
    :foreign_key => 'license_code'

  include Cohorts
  include Publishable
  include SearchModelInterface
  include Archiveable

  validate :valid_url

  def valid_url
    begin
      validated_url = URI.parse(read_attribute(:url))
    rescue Exception
      validated_url = nil
    end
    errors.add(:url, 'must be a valid url') if validated_url.nil?
  end

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

  scope :official, where(:is_official => true)
  scope :contributed, where(:is_official => false)
  scope :archived, where(:is_archived => true)

  def url(learner = nil)
    begin
      uri = URI.parse(read_attribute(:url))
      if learner
        append_query(uri, "learner=#{learner.id}") if append_learner_id_to_url
        append_query(uri, "c=#{learner.user.id}") if append_survey_monkey_uid
        if append_auth_token
          AccessGrant.prune!
          token = learner.user.create_access_token_valid_for(3.minutes)
          append_query(uri, "token=#{token}")
        end
      end
      return uri.to_sc
    rescue
      return read_attribute(:url)
    end
  end

  def material_type
    template_type ? template_type : 'Activity'
  end

  def display_name
    return template.display_name if template
    return ExternalActivity.display_name
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

  # needed to mimic Investigation (investigations/list/filter)
  def duplicateable?(user)
    false
  end

  # methods required by Search::SearchMaterial
  def full_title
    name
  end

  def activities
    template.activities if material_type == 'Investigation'
  end
  # end methods required by Search::SearchMaterial

  def left_nav_panel_width
    300
  end

  def print_listing
    listing = []
  end

  def run_format
    :run_resource_html
  end

  def has_launch_url?
    !launch_url.blank?
  end

  def lara_activity?
    material_type == 'Activity' && has_launch_url?
  end

  def lara_sequence?
    material_type == 'Investigation' && has_launch_url?
  end

  def lara_activity_or_sequence?
    lara_activity? || lara_sequence?
  end

  def options_for_external_report
    ExternalReport.all.map { |r| [r.name, r.id] }
  end

  private

  def append_query(uri, query_str)
    queries = [uri.query, query_str]
    uri.query = queries.compact.join("&")
  end
end
