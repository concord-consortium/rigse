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
    
=begin
    teacher_number = 1;
    teacher_class_count = 0;
    teacher_clazzes = Portal::TeacherClazz.find(:all) # Gives all rows in the portal_teacher_clazzes
    teacher_clazzes.each do |teacher_clazz| # for every row
      if(teacher_number == teacher_clazzes.teacher_id and teacher_class_count != 0) # l
        teacher_class_count += 1;
      else
        teacher_number = teacher_clazzes.teacher_id
        teacher_class_count = 0
      teacher_clazzes.position = teacher_class_count;
=end
  end

  def self.down
    remove_column :portal_teacher_clazzes, :position
  end
end
