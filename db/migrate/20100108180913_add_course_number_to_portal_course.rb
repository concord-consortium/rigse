class AddCourseNumberToPortalCourse < ActiveRecord::Migration
  def self.up
    add_column :portal_courses, :course_number, :string 
    add_index  :portal_courses, :course_number
  end

  def self.down
    remove_column :portal_courses, :course_number 
    remove_index  :portal_courses, :course_number
  end
end
