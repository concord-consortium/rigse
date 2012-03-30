class Portal::StudentClazz < ActiveRecord::Base
  self.table_name = :portal_student_clazzes

  acts_as_replicatable

  belongs_to :clazz, :class_name => "Portal::Clazz", :foreign_key => "clazz_id"
  belongs_to :student, :class_name => "Portal::Student", :foreign_key => "student_id"

  [:name, :description].each { |m| delegate m, :to => :clazz }

  # def before_validation
  #   # Portal::StudentClazz.count(:conditions => "`clazz_id` = '#{self.clazz_id}' AND `student_id` = '#{self.student_id}'") == 0
  #   sc = Portal::StudentClazz.find(:first, :conditions => "`clazz_id` = '#{self.clazz_id}' AND `student_id` = '#{self.student_id}'")
  #   self.id = sc.id
  # end

end
