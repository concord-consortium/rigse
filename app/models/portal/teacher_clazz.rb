class Portal::TeacherClazz < ActiveRecord::Base
  set_table_name :portal_teacher_clazzes
  
  acts_as_replicatable
  
  belongs_to :clazz, :class_name => "Portal::Clazz", :foreign_key => "clazz_id"
  belongs_to :teacher, :class_name => "Portal::Teacher", :foreign_key => "teacher_id"
  
  [:name, :description].each { |m| delegate m, :to => :clazz }
  
  # def before_validation
  #   # Portal::TeacherClazz.count(:conditions => "`clazz_id` = '#{self.clazz_id}' AND `teacher_id` = '#{self.teacher_id}'") == 0
  #   sc = Portal::TeacherClazz.find(:first, :conditions => "`clazz_id` = '#{self.clazz_id}' AND `teacher_id` = '#{self.teacher_id}'")
  #   self.id = sc.id
  # end
  
  # also link/unlink the teacher to/from the class's wordpress blog
  after_create :add_to_blog
  before_destroy :remove_from_blog

  def add_to_blog
    # If we're adding a teacher, but the class only has one teacher,
    # that means the class was just created, so don't bother adding
    # the teacher to the blog since they'll already be associated.
    return if self.clazz.teachers.size == 1
    begin
      wp = Wordpress.new
      wp.add_user_to_clazz(self.teacher, self.clazz, "administrator")
    rescue
    end
  end

  def remove_from_blog
    begin
      wp = Wordpress.new
      wp.remove_user_from_clazz(self.teacher, self.clazz)
    rescue
    end
  end
end
