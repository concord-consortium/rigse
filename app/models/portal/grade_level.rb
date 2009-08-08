class Portal::GradeLevel < ActiveRecord::Base
  set_table_name :portal_grade_levels
  
  acts_as_replicatable
  
  belongs_to :school, :class_name => "Portal::School", :foreign_key => "school_id"
  
  has_many :students, :class_name => "Portal::Student", :foreign_key => "grade_level_id"
  
  has_and_belongs_to_many :teachers, :join_table => "portal_grade_levels_teachers", :class_name => "Portal::Teacher"
  has_and_belongs_to_many :courses, :join_table => "portal_courses_grade_levels", :class_name => "Portal::Course"
end