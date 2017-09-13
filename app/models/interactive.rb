class Interactive < ActiveRecord::Base
  include Cohorts
  include Publishable
  include SearchModelInterface
  include Archiveable

  acts_as_taggable_on :model_types

  attr_accessible :name, :description, :url, :width, :height, :scale, :image_url, :credits, :publication_status, :project_ids, :full_window, :no_snapshots, :save_interactive_state
  alias_attribute :thumbnail_url, :image_url
  belongs_to :user

  has_many :project_materials, :class_name => "Admin::ProjectMaterial", :as => :material, :dependent => :destroy
  has_many :projects, :class_name => "Admin::Project", :through => :project_materials
  has_many :favorites, as: :favoritable

  belongs_to :license,
    :class_name  => 'CommonsLicense',
    :primary_key => 'code',
    :foreign_key => 'license_code'

  before_validation :smart_add_url_protocol

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
      ea.user && ea.user.name
    end

    integer :user_id

    boolean :teacher_only do
      false
    end

    boolean :is_archived do |o|
        o.archived?
    end

    boolean :is_official

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

    time    :updated_at
    time    :created_at

    string  :grade_span do
      nil
    end
    integer :domain_id do
      nil
    end

    string  :material_type do
      "Interactive"
    end

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

    string  :model_types, :multiple => true do
      model_type_list
    end

    integer :project_ids, :multiple => true, :references => Admin::Project

    boolean :is_assessment_item do
      false
    end

    boolean :published do |o|
      o.publication_status == 'published'
    end

  end

  scope :published, where(publication_status: 'published')

  def is_official
    true
  end

  def teacher_only?
    true
  end

  def display_name
    self.name
  end

  protected

  def safe_url(url)
    unless url.blank? || url[/\Ahttp:\/\//] || url[/\Ahttps:\/\//] || url[/\A\/\//]
      url = "//#{url}"
    end
    url
  end

  def smart_add_url_protocol
    self.url = safe_url(self.url)
    self.image_url = safe_url(self.image_url)
  end

end
