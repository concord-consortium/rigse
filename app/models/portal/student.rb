class Portal::Student < ActiveRecord::Base
  self.table_name = :portal_students
  
  acts_as_replicatable
  
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  belongs_to :grade_level, :class_name => "Portal::GradeLevel", :foreign_key => "grade_level_id"
  
  # because of has many polymorphs, we don't need the following relationships defined
  # TODO: Schools must be queried through clazzes.
  # TODO: For now we are writing custom methods...
  # has_many :school_memberships, :as => :member, :class_name => "Portal::SchoolMembership"
  # has_many :schools, :through => :school_memberships, :class_name => "Portal::School"
  
  has_many :learners, :class_name => "Portal::Learner", :foreign_key => "student_id"
  has_many :student_clazzes, :class_name => "Portal::StudentClazz", :foreign_key => "student_id"
  
  has_many :clazzes, :through => :student_clazzes, :class_name => "Portal::Clazz", :source => :clazz
  
  has_many :collaborations, :class_name => "Portal::Collaboration", :foreign_key => "student_id"
  has_many :collaborative_bundles, :through => :collaborations, :class_name => "Dataservice::BundleContent", :source => :bundle_content 

  [:name, :first_name, :last_name, :email, :login, :vendor_interface, :anonymous?, :has_role?].each { |m| delegate m, :to => :user }
  
  include Changeable
  
 
  def self.generate_user_email
    hash = UUIDTools::UUID.timestamp_create.to_s
    "no-email-#{hash}@concord.org"
  end
  
  def self.generate_user_login(first_name, last_name)
    # Old method, first_name + last initial
    #generated_login = "#{first_name.downcase.gsub(/[^a-z0-9]/,'')}#{last_name[0..0].downcase}"
    suggested_login = "#{first_name[0..0].downcase}#{last_name.downcase.gsub(/[^a-z0-9]/,'')}"
    # existing_users = User.find(:all, :conditions => "login RLIKE '#{generated_login}[0-9]*$'", :order => :login)
    counter = 0
    generated_login = suggested_login
    while (User.login_exists? generated_login)
      counter = counter + 1
      generated_login = "#{suggested_login}#{counter}"
    end
    return generated_login
  end
  
  ## TODO: fix with has_many finderSQL
  def schools
    schools = self.clazzes.map {|c| c.school }.uniq.flatten
  end

  def school
    return schools.last
  end

  def teachers
    teachers = self.clazzes.map {|c| c.teachers }.flatten.uniq
  end

  def has_teacher?(teacher)
    self.teachers.include?(teacher)
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

  def process_class_word(class_word)
    if clazz = Portal::Clazz.find_by_class_word(class_word)
      unless self.student_clazzes.find_by_clazz_id(clazz.id)
        self.student_clazzes.create!(:clazz_id => clazz.id, :student_id => self.id, :start_time => Time.now)
      end
    else
      nil
    end
  end
  
  def has_clazz?(clazz)
    self.clazzes.detect { |cl| cl.id == clazz.id }
  end
  
  def add_clazz(clazz)
    unless self.has_clazz?(clazz)
      self.clazzes << clazz
    end
  end

end
