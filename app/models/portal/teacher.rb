class Portal::Teacher < ActiveRecord::Base
  set_table_name :portal_teachers
  
  acts_as_replicatable
  
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  
  # because of has many polymorphs, we SHOULDN't need the following relationships defined, but
  # HACK: noah went ahead, and explicitly defined them, because it wasn't working.
  has_many :school_memberships, :as => :member
  has_many :schools, :through => :school_memberships
  
  has_many :subjects, :class_name => "Portal::Subject", :foreign_key => "teacher_id"
  has_many :clazzes, :class_name => "Portal::Clazz", :foreign_key => "teacher_id"
  
  has_and_belongs_to_many :grade_levels, :join_table => "portal_grade_levels_teachers", :class_name => "Portal::GradeLevel"
  
  [:name, :first_name, :login, :password, :last_name, :email, :vendor_interface].each { |m| delegate m, :to => :user }
  
  include Changeable
  
  
  ##
  ##
  ##
  def school_ids
    schools.map { |s| s.id }
  end
  
  def school_ids=(ids)
    self.schools = ids.map { |i| Portal::School.find(i)}
  end
  
  ##
  ##
  ##
  def children
    clazzes
  end
  
  ##
  ## sort of a hack
  ##
  def parent
    nil
  end
  
end