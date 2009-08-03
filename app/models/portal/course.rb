class Portal::Course < ActiveRecord::Base
  set_table_name :portal_courses
  
  acts_as_replicatable
  
  belongs_to :school, :class_name => "Portal::School", :foreign_key => "school_id"
  
  has_many :clazzes, :class_name => "Portal::Clazz", :foreign_key => "course_id"
  has_and_belongs_to_many :grade_levels, :join_table => "portal_courses_grade_levels", :class_name => "Portal::GradeLevel"
end