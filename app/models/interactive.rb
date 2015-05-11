class Interactive < ActiveRecord::Base
  include Publishable
  include Changeable
  include SearchModelInterface
  
  acts_as_taggable_on :model_types
  
  attr_accessible :name, :description, :url, :width, :height, :scale, :image_url, :credits, :publication_status
  alias_attribute :thumbnail_url, :image_url
  belongs_to :user

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
    boolean :published do |ea|
      ea.publication_status == 'published'
    end

    boolean :teacher_only do
      false
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

    #string  :java_requirements
    string  :cohorts, :multiple => true do
      cohort_list
    end
    string  :grade_levels, :multiple => true do
      grade_level_list
    end
    string  :subject_areas, :multiple => true do
      subject_area_list
    end
    string  :model_types, :multiple => true do
      model_type_list
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
