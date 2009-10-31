class Portal::Teacher < ActiveRecord::Base
  set_table_name :portal_teachers
  
  acts_as_replicatable
  
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  belongs_to :domain
  
  has_many :offerings, :as => :runnable, :class_name => "Portal::Offering"
  
  has_many :grade_levels, :as => :has_grade_levels, :class_name => "Portal::GradeLevel"
  has_many :grades, :through => :grade_levels, :class_name => "Portal::Grade"

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
  
  [:first_name, :login, :password, :last_name, :email, :vendor_interface, :anonymous?, :has_role?].each { |m| delegate m, :to => :user }
  
  validates_presence_of :user,  :message => "user association not specified"
  
  def name
    user ? user.name : 'unnamed teacher'
  end
        
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