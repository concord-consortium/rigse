class Portal::TeacherClazz < ActiveRecord::Base
  self.table_name = :portal_teacher_clazzes
  
  acts_as_replicatable
  
  belongs_to :clazz, :class_name => "Portal::Clazz", :foreign_key => "clazz_id"
  belongs_to :teacher, :class_name => "Portal::Teacher", :foreign_key => "teacher_id"
  default_scope :order => 'position ASC'
  
  [:name, :description].each { |m| delegate m, :to => :clazz }
  
  # def before_validation
  #   # Portal::TeacherClazz.count(:conditions => "`clazz_id` = '#{self.clazz_id}' AND `teacher_id` = '#{self.teacher_id}'") == 0
  #   sc = Portal::TeacherClazz.find(:first, :conditions => "`clazz_id` = '#{self.clazz_id}' AND `teacher_id` = '#{self.teacher_id}'")
  #   self.id = sc.id
  # end
  
  before_save do |teacher_clazz|
    if teacher_clazz.id.nil?
      position = teacher_clazz.teacher.teacher_clazzes.length + 1
      teacher_clazz.position = position
    end
  end
  
end
