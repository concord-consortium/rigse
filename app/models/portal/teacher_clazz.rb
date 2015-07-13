class Portal::TeacherClazz < ActiveRecord::Base
  self.table_name = :portal_teacher_clazzes
  
  acts_as_replicatable
  
  belongs_to :clazz, :class_name => "Portal::Clazz", :foreign_key => "clazz_id"
  belongs_to :teacher, :class_name => "Portal::Teacher", :foreign_key => "teacher_id"
  default_scope :order => 'position ASC'
  
  [:name, :description].each { |m| delegate m, :to => :clazz }

  # NOTE: Here position is being set relative to the teacher.
  # In clazzes_controller#manage_classes position is being explicitly set.
  # There is a conflict about how we want to scope 'position'.
  # The controller wants to scope it to clazz, which should be the
  # right way to do it. This is a hack is to support the 'default' teacher.
  # It should be reconsidered.
  before_save do |teacher_clazz|
    if teacher_clazz.id.nil?
      position = teacher_clazz.teacher.teacher_clazzes.length + 1
      teacher_clazz.position = position
    end
  end
  
end
