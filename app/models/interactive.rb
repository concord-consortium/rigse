class Interactive < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user

  acts_as_taggable_on :grade_levels
  acts_as_taggable_on :subject_areas
  acts_as_taggable_on :model_types

end
