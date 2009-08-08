class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :portal_courses do |t|

      t.string    :uuid, :limit => 36
      t.string    :name
      t.text      :description
      
      t.integer   :school_id
      
      t.string    :status

      t.timestamps
    end
    
    create_table :portal_courses_grade_levels, :id => false do |t|
      t.integer :grade_level_id
      t.integer :course_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :portal_courses_grade_levels
    drop_table :portal_courses
  end
end
