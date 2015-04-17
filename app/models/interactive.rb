class Interactive < ActiveRecord::Base
  include Publishable
  include Changeable
  include SearchModelInterface

  attr_accessible :name, :description, :url, :width, :height, :scale, :image_url, :credits, :publication_status
  belongs_to :user

  #acts_as_taggable_on :grade_levels
  #acts_as_taggable_on :subject_areas
  acts_as_taggable_on :model_types

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
    boolean :is_template
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
    string  :material_type
    string  :java_requirements
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

  def is_template
    false
  end

  def is_official
    true
  end

  def material_type
   'Interactive'
  end

  def teacher_only
    true
  end
  
  def teacher_only?
    true
  end

  def display_name
    self.name
  end

end
