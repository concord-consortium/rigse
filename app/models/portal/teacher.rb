class Portal::Teacher < ActiveRecord::Base
  set_table_name :portal_teachers
  
  acts_as_replicatable
  
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  
  # because of has many polymorphs, we SHOULDN't need the following relationships defined, but
  # HACK: noah went ahead, and explicitly defined them, because it wasn't working.
  #
  # And now (20090813) it appears to be working so I've commented it out.
  # It's presence was generating duplicate school_membership models when a Teacher registered.
  #
  # has_many :school_memberships, :as => :member, :class_name => "Portal::SchoolMembership"
  # has_many :schools, :through => :school_memberships, :class_name => "Portal::School", :uniq => true
  
  has_many :subjects, :class_name => "Portal::Subject", :foreign_key => "teacher_id"
  has_many :clazzes, :class_name => "Portal::Clazz", :foreign_key => "teacher_id", :source => :clazz
  
  has_and_belongs_to_many :grade_levels, :join_table => "portal_grade_levels_teachers", :class_name => "Portal::GradeLevel"
  
  [:name, :first_name, :login, :password, :last_name, :email, :vendor_interface].each { |m| delegate m, :to => :user }
  
  include Changeable

  class <<self
    def display_name
      "Teacher"
    end
  end
  
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