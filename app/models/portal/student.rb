class Portal::Student < ActiveRecord::Base
  set_table_name :portal_students
  
  acts_as_replicatable
  
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  belongs_to :grade_level, :class_name => "Portal::GradeLevel", :foreign_key => "grade_level_id"
  
  # because of has many polymorphs, we don't need the following relationships defined
  has_many :school_memberships, :as => :member
  has_many :schools, :through => :school_memberships
  
  has_many :learners, :class_name => "Portal::Learner", :foreign_key => "student_id"
  has_many :student_clazzes, :class_name => "Portal::StudentClazz", :foreign_key => "student_id"
  
  has_many :clazzes, :through => :student_clazzes, :class_name => "Portal::Clazz"
  
  [:name, :first_name, :last_name, :email, :login, :vendor_interface].each { |m| delegate m, :to => :user }
  
  include Changeable
  
  def self.generate_user_email
    hash = UUIDTools::UUID.timestamp_create.to_s
    "no-email-#{hash}@concord.org"
  end
  
  def self.generate_user_login(first_name, last_name)
    generated_login = "#{first_name.downcase.gsub(/[^a-z0-9]/,'')}#{last_name[0..0].downcase}"
    existing_users = User.find(:all, :conditions => "login RLIKE '#{generated_login}[0-9]*$'", :order => :login)
    if existing_users.size > 0
      generated_login << "#{existing_users.size + 1}"
    end
    return generated_login
  end
  
  ##
  ## Strange approach to alter the behavior of Clazz.children()
  ## to reflect a student-centric world view.
  ## ... (possibly a bad idea?)
  module FixupClazzes
    def children
      return offerings
    end
  end
    
  ##
  ## required for the accordion view
  ##
  def children
    clazzes.map! {|c| c.extend(FixupClazzes)}
  end

  
end