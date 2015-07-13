class Portal::TeacherClazz < ActiveRecord::Base
  self.table_name = :portal_teacher_clazzes
  
  acts_as_replicatable
  acts_as_list :scope => :teacher
  
  belongs_to :clazz, :class_name => "Portal::Clazz", :foreign_key => "clazz_id"
  belongs_to :teacher, :class_name => "Portal::Teacher", :foreign_key => "teacher_id"
  default_scope :order => 'position ASC'
  
  [:name, :description].each { |m| delegate m, :to => :clazz }
  
end
