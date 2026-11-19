class Portal::Teacher < ApplicationRecord
  include Cohorts

  self.table_name = :portal_teachers

  acts_as_replicatable
  acts_as_taggable_on :grade_levels
  acts_as_taggable_on :subject_areas

  belongs_to :user, :class_name => "User", :foreign_key => "user_id", :inverse_of => :portal_teacher
  # The teacher's learner account, used for learner mode. Nil until first use.
  belongs_to :teacher_learner, :class_name => "Portal::Student", :optional => true, :inverse_of => :linked_teacher

  has_many :grade_levels, :as => :has_grade_levels, :class_name => "Portal::GradeLevel"
  has_many :grades, :through => :grade_levels, :class_name => "Portal::Grade"

  has_many :offering_full_status, :class_name => "Portal::TeacherFullStatus", :foreign_key => "teacher_id"

  # because of has many polymorphs, we SHOULDN't need the following relationships defined, but
  # HACK: noah went ahead, and explicitly defined them, because it wasn't working.
  #
  # And now (20090813) it appears to be working so I've commented it out.
  # It's presence was generating duplicate school_membership models when a Teacher registered.


  has_many :school_memberships, :dependent => :destroy , :as => :member, :class_name => "Portal::SchoolMembership"
  has_many :schools, -> { distinct }, :through => :school_memberships, :class_name => "Portal::School"

  has_many :subjects, :dependent => :destroy, :class_name => "Portal::Subject", :foreign_key => "teacher_id"

  # Used to be that clazzes has a teacher_id field, now we use a mapping table like students
  # to support common case of multiple teachers per class
  # has_many :clazzes, :class_name => "Portal::Clazz", :foreign_key => "teacher_id", :source => :clazz
  has_many :teacher_clazzes, :dependent => :destroy, :class_name => "Portal::TeacherClazz", :foreign_key => "teacher_id"
  has_many :clazzes, :through => :teacher_clazzes, :class_name => "Portal::Clazz"
  has_many :offerings, :through => :clazzes
  
  has_many :projects, -> { distinct }, :through => :cohorts, :class_name => "Admin::Project"

  has_many :teacher_project_views, :class_name => "TeacherProjectView"
  has_many :viewed_projects, :through => :teacher_project_views, :class_name => "Admin::Project"

  [:first_name, :login, :password, :last_name, :email, :anonymous?, :has_role?].each { |m| delegate m, :to => :user }

  validates_presence_of :user,  :message => "user association not specified"

  after_create :add_to_default_cohort
  # Deleting a teacher deletes their learner account. User#destroy reaches this through
  # User's `has_one :portal_teacher, dependent: :destroy`.
  # `lock!` waits for find_or_create_teacher_learner! and reloads, so the link is fresh.
  before_destroy :lock!
  after_destroy :destroy_teacher_learner_user

  # Returns the User of this teacher's learner account (used for learner mode),
  # creating it on first use. Raises if the account cannot be created; nothing is
  # saved in that case.
  def find_or_create_teacher_learner!
    transaction do
      # Lock this teacher row before checking the link. Without the lock, two requests at
      # the same time (for example a double click) could both see no link and each
      # create a learner account. `lock!` also reloads, so the link check below is fresh.
      lock!
      if teacher_learner
        teacher_learner.user
      else
        create_teacher_learner_user!
      end
    end
  end

  # Added to force Teachers to belong to at least one school, virtual or otherwise.
  # There should be no Teachers without schools, but if there are any that predate this change,
  # it could cause problems, so it's disabled until we discuss it further. -- Cantina-CMH 6/9/10
  #validates_presence_of :schools, :message => "association cannot be empty"

  @@LEFT_PANE_ITEM = {
    'NONE' => 0,
    'MATERIALS' => 1,
    'STUDENT_ROSTER' => 2,
    'CLASS_SETUP' => 3,
    'FULL_STATUS' => 4,
    'LINKS' => 5
  }

  def self.LEFT_PANE_ITEM
    return @@LEFT_PANE_ITEM
  end

  def self.save_left_pane_submenu_item(current_visitor, item_value)
    if current_visitor.nil? or current_visitor.portal_teacher.nil?
      return
    end

    portal_teacher = current_visitor.portal_teacher

    portal_teacher.save_left_pane_submenu_item(item_value)
  end

  def self.can_author?
    return Admin::Settings.teachers_can_author?
  end

  def self.update_authoring_roles
    if self.can_author?
      self.all.each do |teacher|
        teacher.user.add_role('author') if teacher.user
      end
    end
  end


  def save_left_pane_submenu_item(item_value)
    self.left_pane_submenu_item = item_value
    self.save!
  end

  def name
    user ? user.name : 'unnamed teacher'
  end

  def list_name
    user ? "#{user.last_name}, #{user.first_name[0, 1].upcase}. (#{user.login})" : "unnamed teacher"
  end

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

  def school_names
    schools.map { |s| s.name }
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

  def students
    students = clazzes.to_a.map { |c| c.students }
    students.flatten.compact
  end
  def has_clazz?(clazz)
    self.clazzes.detect { |cl| cl.id == clazz.id }
  end

  def add_clazz(clazz)
    unless self.has_clazz?(clazz)
      self.clazzes << clazz
    end
  end

  def remove_clazz(clazz)
    self.clazzes.delete clazz
  end

  def school
    return schools.first
  end

  def possibly_add_authoring_role
    if self.class.can_author?
      self.user.add_role('author')
    end
  end

  def my_classes_url(protocol, host)
    Rails.application.routes.url_helpers.api_v1_classes_mine(protocol: protocol, host: host)
  end

  def record_project_view(project)
    project_view = self.teacher_project_views.where(viewed_project_id: project.id).first_or_create
    project_view.touch
  end

  private

  def add_to_default_cohort
    default_cohort = Admin::Settings.default_settings && Admin::Settings.default_settings.default_cohort
    if default_cohort
      self.cohorts << default_cohort
    end
  end

  # Called only by find_or_create_teacher_learner!, inside its transaction, with this row locked.
  # Follows API::V1::StudentsController#register. There is no retry if the generated login is
  # taken at the same moment: that is very rare, and the save then fails and rolls back.
  def create_teacher_learner_user!
    password = SecureRandom.hex(32)
    learner_user = User.new(
      first_name: user.first_name,
      last_name: user.last_name,
      login: Portal::Student.generate_user_login(user.first_name, user.last_name),
      email: Portal::Student.generate_user_email,
      # Nobody is told this password, so nobody can sign in to this account directly.
      password: password,
      password_confirmation: password,
      require_password_reset: false,
      asked_age: user.asked_age,
      have_consent: user.have_consent,
      of_consenting_age: user.of_consenting_age
    )
    learner_user.skip_notifications = true
    learner_user.save!
    # Devise does not sign in an unconfirmed user.
    raise ActiveRecord::RecordNotSaved.new("Could not confirm the learner account", learner_user) unless learner_user.confirm

    student = Portal::Student.create!(user: learner_user, is_teacher_learner: true)
    update!(teacher_learner: student)
    learner_user
  end

  def destroy_teacher_learner_user
    teacher_learner&.user&.destroy
  end

end
