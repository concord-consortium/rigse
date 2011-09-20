class Portal::StudentClazz < ActiveRecord::Base
  set_table_name :portal_student_clazzes

  acts_as_replicatable

  belongs_to :clazz, :class_name => "Portal::Clazz", :foreign_key => "clazz_id"
  belongs_to :student, :class_name => "Portal::Student", :foreign_key => "student_id"

  [:name, :description].each { |m| delegate m, :to => :clazz }

  # def before_validation
  #   # Portal::StudentClazz.count(:conditions => "`clazz_id` = '#{self.clazz_id}' AND `student_id` = '#{self.student_id}'") == 0
  #   sc = Portal::StudentClazz.find(:first, :conditions => "`clazz_id` = '#{self.clazz_id}' AND `student_id` = '#{self.student_id}'")
  #   self.id = sc.id
  # end

  # also link/unlink the student to/from the class's wordpress blog
  after_create :add_to_blog
  before_destroy :remove_from_blog

  def add_to_blog
    begin
      wp = Wordpress.new
      wp.add_user_to_clazz(self.student, self.clazz, "author")
    rescue
    end
  end

  def remove_from_blog
    begin
      wp = Wordpress.new
      wp.remove_user_from_clazz(self.student, self.clazz)
    rescue
    end
  end
end
