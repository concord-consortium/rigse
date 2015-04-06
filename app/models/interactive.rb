class Interactive < ActiveRecord::Base
  include Publishable

  attr_accessible :name, :description, :url, :width, :height, :scale, :image_url, :credits, :publication_status
  belongs_to :user

  acts_as_taggable_on :grade_levels
  acts_as_taggable_on :subject_areas
  acts_as_taggable_on :model_types

  searchable do
    string :name
    text :description
    string  :grade_levels, :multiple => true do
      grade_level_list
    end
    string  :subject_areas, :multiple => true do
      subject_area_list
    end
    string  :model_types, :multiple => true do
      model_type_list
    end
    boolean :published do
      publication_status == 'published'
    end
    boolean :is_official
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
