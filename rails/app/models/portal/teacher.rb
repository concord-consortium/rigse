class Portal::Teacher < ApplicationRecord
  include Cohorts

  self.table_name = :portal_teachers

  acts_as_replicatable
  acts_as_taggable_on :grade_levels
  acts_as_taggable_on :subject_areas

  belongs_to :user, :class_name => "User", :foreign_key => "user_id", :inverse_of => :portal_teacher

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

end
