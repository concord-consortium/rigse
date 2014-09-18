class Portal::Student < ActiveRecord::Base
  self.table_name = :portal_students

  acts_as_replicatable

  belongs_to :user, :class_name => "User", :foreign_key => "user_id", :inverse_of => :portal_student
  belongs_to :grade_level, :class_name => "Portal::GradeLevel", :foreign_key => "grade_level_id"

  # because of has many polymorphs, we don't need the following relationships defined
  # TODO: Schools must be queried through clazzes.
  # TODO: For now we are writing custom methods...
  # has_many :school_memberships, :as => :member, :class_name => "Portal::SchoolMembership"
  # has_many :schools, :through => :school_memberships, :class_name => "Portal::School"

  has_many :learners, :dependent => :destroy , :class_name => "Portal::Learner", :foreign_key => "student_id"
  has_many :student_clazzes, :dependent => :destroy, :class_name => "Portal::StudentClazz", :foreign_key => "student_id"

  has_many :clazzes, :through => :student_clazzes, :class_name => "Portal::Clazz", :source => :clazz

  has_many :own_collaborations, :class_name => "Portal::Collaboration", :foreign_key => "owner_id"
  has_many :collaboration_memberships, :class_name => "Portal::CollaborationMembership"
  has_many :collaborations, :through => :collaboration_memberships, :class_name => "Portal::Collaboration"
  has_many :collaborative_bundles, :through => :collaborations, :class_name => "Dataservice::BundleContent", :source => :bundle_content

  has_many :portal_student_permission_forms, :dependent => :destroy, :class_name => "Portal::StudentPermissionForm", :foreign_key => "portal_student_id"

  has_many :permission_forms,
    :through      => :portal_student_permission_forms,
    :class_name   => "Portal::PermissionForm",
    :source       => :portal_permission_form,
    :after_add    => :update_report_permissions,
    :after_remove => :update_report_permissions

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
    # Disable cache as we have higher chance to avoid race condition causing that the generated login
    # is not unique. Also it's needed when we actually handle that situation (see student_registration.rb),
    # as otherwise subsequent login generation could return the same result as previous call.
    ActiveRecord::Base.uncached do
      while (User.login_exists? generated_login)
        counter = counter + 1
        generated_login = "#{suggested_login}#{counter}"
      end
    end
    return generated_login
  end

  def update_report_permissions(permission_form)
    report_learners = Report::Learner.where(:student_id => self.id)
    report_learners.each { |l| l.update_permission_forms; l.save }
  end

  ## TODO: fix with has_many finderSQL
  def schools
    schools = self.clazzes.map {|c| c.school }.uniq.flatten.compact
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
