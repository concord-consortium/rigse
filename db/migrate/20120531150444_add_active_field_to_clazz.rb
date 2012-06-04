class AddActiveFieldToClazz < ActiveRecord::Migration
  def self.up
    add_column :portal_teacher_clazzes, :active, :integer, :default=>1
    teacher_clazzes = Portal::TeacherClazz.find(:all)
    teacher_clazzes.each do |teacher_clazz|
      teacher_clazz.active = 1 
      teacher_clazz.save!
    end
  end

  def self.down
    remove_column :portal_teacher_clazzes, :active
  end
end
