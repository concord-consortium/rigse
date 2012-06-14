class AddPositionFieldToClazz < ActiveRecord::Migration
  
  class Portal::TeacherClazz < ActiveRecord::Base
    set_table_name :portal_teacher_clazzes
  end 
  
  def self.up
    add_column :portal_teacher_clazzes, :position, :integer, :default=>0
    Portal::TeacherClazz.reset_column_information
    teachers = Portal::Teacher.all
    teachers.each do |teacher|
      teacher_clazzes = teacher.teacher_clazzes
      position = 1
      teacher_clazzes.each do |teacher_clazz|
        teacher_clazz.position = position
        teacher_clazz.save!
        position += 1
      end
    end
  end

  def self.down
    remove_column :portal_teacher_clazzes, :position
  end
end
