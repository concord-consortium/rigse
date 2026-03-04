require 'uri'
class ExternalActivity < ApplicationRecord

  # Possible options for source type attribute. For now it's hardcoded. In the future, we might change
  # that to entities living in a database, so it's easier to add new source types.
  SOURCE_TYPE_OPTIONS = [
    ["none", nil],
    ["LARA", "LARA"]
  ]

  #
  # see https://github.com/sunspot/sunspot/blob/master/README.md
  #
  searchable do
    text :name
    string :name
    text :long_description
    text :long_description_for_teacher do
      nil
    end
    text :content do
      nil
    end

    text :keywords

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

    boolean :teacher_only do
      # Useful in Activity and Investigation; stubbed here
      false
    end
    integer :offerings_count

    time    :updated_at
    time    :created_at

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

  belongs_to :tool

  belongs_to :user

  has_many :external_activity_reports
  has_many :external_reports, through: :external_activity_reports

  has_many :favorites, as: :favoritable

  # offerings are not deleted if they have learners, so you need to explicitly remove the learners
  # before you can delete the offering
  has_many :offerings, :dependent => :destroy, :as => :runnable, :class_name => "Portal::Offering"

  has_many :materials_collection_items, :dependent => :destroy, :as => :material
  has_many :materials_collections, :through => :materials_collection_items

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

  #
  # Override the material_type method from SearchModelInterface
  #
  def material_type
    attributes['material_type']
  end

  validate :valid_url

  def valid_url
    begin
      validated_url = URI.parse(read_attribute(:url))
    rescue Exception
      validated_url = nil
    end
    errors.add(:url, 'must be a valid url') if validated_url.nil?
  end

  scope :published, -> { where(publication_status: "published") }

  scope :assigned, -> { where('offerings_count > 0') }

  scope :not_private, -> { where("#{self.table_name}.publication_status IN ('published', 'draft')") }

  scope :by_user, proc { |u| where(:user_id => u.id) }

  scope :ordered_by, lambda { |order| order(order) }

  scope :official, -> { where(is_official: true) }
  scope :contributed, -> { where(is_official: false) }
  scope :archived, -> { where(is_archived: true) }

  def url(learner = nil, domain = nil)
    begin
      uri = URI.parse(read_attribute(:url))
      if learner
        append_query(uri, "learner=#{learner.id}") if append_learner_id_to_url
        append_query(uri, "c=#{learner.user.id}") if append_survey_monkey_uid
        if append_auth_token
          token = SignedJwt::create_portal_token(learner.user, {learner_id: learner.id, user_type: "learner"}, 180)
          append_query(uri, "token=#{token}")
          append_query(uri, "domain=#{domain}&domain_uid=#{learner.user.id}") if domain
        end
      end
      return uri.to_s
    rescue
      return read_attribute(:url)
    end
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

  # methods required by Search::SearchMaterial
  def full_title
    name
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

  def lara_activity_or_sequence?
    if self.tool && self.tool.source_type == 'LARA'
      return true
    else
      return false
    end
  end

  def options_for_external_report
    ExternalReport.all.map { |r| [r.name, r.id] }
  end

  # If user is a teacher and long_description_for_teacher is available, it returns long_description_for_teacher.
  # Otherwise it returns long_description if it is available.
  # The last fallback is an short description.
  def long_description_for_user(user)
    return long_description_for_teacher if user && user.portal_teacher && long_description_for_teacher.present?
    return long_description if long_description.present?
    short_description
  end

  # 2019-07-12 NP: Backwards compatibility note
  # We removed external_report from the table, but support many via
  # external_activity_reports
  def external_report
    return external_reports.first
  end

  def add_to_collections(collection_ids)
    collection_ids.each do |collection_id|
      collection = MaterialsCollection.includes(:materials_collection_items).find(collection_id)
      collection_items = collection.materials_collection_items
      item = collection_items.find_by_material_id_and_material_type(id, "ExternalActivity")
      if item.nil?
        item = MaterialsCollectionItem
                   .where(materials_collection_id: collection.id,
                          material_type: "ExternalActivity",
                          material_id: id)
                   .first_or_create
      end
      if item.position.nil?
        item.position = collection_items.length
        item.save!
      end
    end
  end

  private

  def append_query(uri, query_str)
    queries = [uri.query, query_str]
    uri.query = queries.compact.join("&")
  end
end
