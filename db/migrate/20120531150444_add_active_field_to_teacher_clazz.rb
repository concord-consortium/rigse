class AddActiveFieldToTeacherClazz < ActiveRecord::Migration

  # faux model for successful migration
  class Portal::TeacherClazz < ActiveRecord::Base
    set_table_name :portal_teacher_clazzes
  end
  
  
  def self.up
    add_column :portal_teacher_clazzes, :active, :boolean, :default=>true
    Portal::TeacherClazz.reset_column_information
    portal_clazzes = Portal::TeacherClazz.all
    portal_clazzes.each do |teacher_clazz|
      teacher_clazz.active = true 
      teacher_clazz.save!
    end
  end

  def self.down
    remove_column :portal_teacher_clazzes, :active
  end 
end