class Portal::Clazz < ApplicationRecord
  self.table_name = :portal_clazzes

  acts_as_replicatable

  belongs_to :course, :class_name => "Portal::Course", :foreign_key => "course_id"

  has_many :offerings, -> { order :position },
    dependent: :destroy,
    class_name: 'Portal::Offering',
    foreign_key: 'clazz_id'

  has_many :active_offerings, -> { where(active: true).order(:position) },
    class_name: 'Portal::Offering',
    foreign_key: 'clazz_id'

  has_many :student_clazzes, :dependent => :destroy, :class_name => "Portal::StudentClazz", :foreign_key => "clazz_id"
  has_many :students, :through => :student_clazzes, :class_name => "Portal::Student"

  has_many :teacher_clazzes, :dependent => :destroy, :class_name => "Portal::TeacherClazz", :foreign_key => "clazz_id"
  has_many :teachers, :through => :teacher_clazzes, :class_name => "Portal::Teacher"

  has_many :grade_levels, :dependent => :destroy, :as => :has_grade_levels, :class_name => "Portal::GradeLevel"
  has_many :grades, :through => :grade_levels, :class_name => "Portal::Grade"

  has_many :bookmarks

  before_validation :class_word_lowercase
  before_validation :class_word_strip
  validates_presence_of :class_word
  validates_uniqueness_of :class_word, :case_sensitive => false
  validates_presence_of :name

  before_save :generate_class_hash

  include Changeable

  # String constants for error messages -- Cantina-CMH 6/2/10
  ERROR_UNAUTHORIZED = "You are not allowed to modify this class."
  ERROR_REMOVE_TEACHER_LAST_TEACHER = "You cannot remove the last teacher from this class."
  #ERROR_REMOVE_TEACHER_CURRENT_USER = "You cannot remove yourself from this class."

  # JavaScript confirm messages -- Cantina-CMH 6/9/10
  def self.WARNING_REMOVE_TEACHER_CURRENT_USER(clazz_name)
    "This action will remove YOU from the class: #{clazz_name}.\n\nIf you remove yourself, you will lose all access to this class. Are you sure you want to do this?"
  end
  def self.CONFIRM_REMOVE_TEACHER(teacher_name, clazz_name)
    "This action will remove the teacher: '#{teacher_name}' from the class: #{clazz_name}. \nAre you sure you want to do this?"
  end

  self.extend SearchableModel

  @@searchable_attributes = %w{name description}

  class <<self
    def default_class
      find_or_create_default_class
    end

    def find_or_create_default_class
      where(default_class: true).first ||
        Portal::Clazz.create(:name => "Default Class", :default_class => true, :class_word => "default")
    end

    def searchable_attributes
      @@searchable_attributes
    end
  end

  def self.random_class_word(course)
    string = (0..5).map{ ('a'..'z').to_a[rand(26)] }.join
    "#{course.id}_#{string}"
  end

  def title
    "Class: #{name}"
  end

  def teachers_label
    self.teachers.size > 1 ? "Teachers" : "Teacher"
  end

  def teachers_listing
    return "no teachers" unless self.teachers.size > 0
    return self.teachers.collect { |t| t.name }.join(", ")
  end

  # for the accordion display
  def children
    # return students
    return offerings
  end

  def user
    if self.teacher
      return self.teacher.user
    end
    nil
  end

  # this is for changeable?
  # changeable_mod for multiple teachers
  # alias _changeable? changeable?
  def is_user?(_user)
    teacher = _user.class == User ? _user.portal_teacher : _user
    teachers.include? teacher
  end
  alias is_teacher? is_user?

  def is_student?(_user)
    students.include? _user.portal_student
  end

  # def changeable?(_user)
  #   return true if virtual? && is_user?(_user)
  #   if _user.has_role?('manager','admin','district_admin')
  #     return true
  #   end
  #   return false
  # end
  #
  #
  def parent
    return teacher
  end

  #
  # [:district, :virtual?, :real?].each {|method| delegate method, :to=> :course }

  def district
    if course
      return course.district
    end
    return nil
  end

  def virtual?
    if course
      return course.virtual?
    end
    return true
  end

  def real?
    return (! virtual?)
  end

  def school
    if course
      return course.school
    end
    return nil
  end

  # HACK: to support transitioning to multiple teachers.
  def teacher
    self.teachers.first
  end

  # HACK: to support transitioning to multiple teachers.
  def teacher=(_teacher)
    add_teacher(_teacher)
  end

  def has_teacher?(_teacher)
    self.teachers.detect { |t| t.id == _teacher.id }
  end

  def add_teacher(_teacher)
    unless self.has_teacher?(_teacher)
      self.teachers << _teacher
    end
  end

  # This method is used to check whether a user is allowed to remove a specific teacher from this class
  # @attempting_user : User object initiating the request
  # @target_teacher  : Portal::Teacher object to be deleted
  # return values:
  #   nil    : User is allowed to remove this teacher
  #   String : reason why user is not allowed to remove this teacher
  def reason_user_cannot_remove_teacher_from_class(attempting_user, target_teacher)
    # Possible reasons for illegality:
    # - user is not allowed to edit this class at all
    # - user is trying to remove the last teacher from this class
    # - user is trying to remove themselves from this class

    return ERROR_UNAUTHORIZED if attempting_user.nil? || !changeable?(attempting_user)
    return ERROR_REMOVE_TEACHER_LAST_TEACHER if teachers.size == 1
    #return ERROR_REMOVE_TEACHER_CURRENT_USER if target_teacher.user == attempting_user

    nil
  end

  def refresh_saveable_response_objects
    self.offerings.each { |o| o.refresh_saveable_response_objects }
  end

  def class_word_lowercase
    self.class_word.downcase! if self.class_word
  end

  def class_word_strip
    self.class_word.strip! if self.class_word
  end

  # NOTE: this should only be called by offerings_with_default_classes
  # TODO: make protected method
  def offerings_including_default_class
    return self.active_offerings if self.default_class
    offerings = self.active_offerings.clone
    final_offers = []
    offerings.each do |offering|
      # TODO: ensure that the offerings are in the default class?
      # the 'default' flag in offerings seems to be redundant, possibly confusing ...
      default_offerings = Portal::Offering.find_all_using_runnable_id_and_runnable_type_and_default_offering(offering.runnable_id, offering.runnable_type,true)
      case default_offerings.size
      when 0
        final_offers << offering
        next
      when 1
        final_offers << default_offerings.first
        next
      end
      final_offers <<  default_offerings.first
      logger.warn("multiple default offerings with the same runnable ids: #{default_offerings.map {|o| o.id}} type: #{default_offerings.first.runnable_type} id: #{default_offerings.first.runnable_id}")
    end
    final_offers
  end

  def offerings_with_default_classes(user=nil)
    return self.offerings_including_default_class unless (user && user.portal_student && self.default_class)
    real_classes            = user.portal_student.clazzes.to_a.reject { |c| c.default_class }
    real_offering_runnables = real_classes.map{ |c| c.active_offerings.map { |o| o.runnable } }.flatten.uniq.compact
    default_offerings       = self.active_offerings.reject { |o| real_offering_runnables.include?(o.runnable) }
    default_offerings
  end

  def teacher_visible_offerings
    self.offerings.includes(:runnable).select{ |o| (! o.runnable.archived?) }
  end

  def student_visible_offerings
    self.active_offerings.includes(:runnable).select{ |o| (! o.runnable.archived?) }
  end

  def update_offering_position(offering, new_pos)
    class_offerings = offering.clazz.teacher_visible_offerings
    old_pos = class_offerings.index(offering)
    class_offerings.each_with_index do |off, index|
      if off == offering
        # Update given offering.
        off.position = new_pos
      elsif new_pos > old_pos && index > old_pos && index <= new_pos
        # Move items up.
        off.position = index - 1
      elsif new_pos < old_pos && index >= new_pos && index < old_pos
        # Move items down.
        off.position = index + 1
      else
        # Make sure that positions are normalized and correct.
        off.position = index
      end
      off.save!
    end
  end

  def update_offerings_position
    offerings = self.offerings.sort {|a,b| a.position <=> b.position}
    position = 1
    offerings.each do|offering|
      offering.position = position
      offering.save
      position += 1
    end
  end

  def strip_white_space
    self.name = self.name.strip if self.name
    self.description = self.description.strip if self.description
    self.class_word = self.class_word.strip if self.class_word
  end

  def generate_class_hash
    self.class_hash = SecureRandom.hex(24) if self.class_hash.nil?
  end

  def class_info_url(protocol, host)
    Rails.application.routes.url_helpers.api_v1_class_url(id: self.id, protocol: protocol, host: host)
  end

  def external_class_reports
    self.offerings.includes(:runnable)
      .select{ |o| o.runnable && o.runnable.respond_to?(:external_reports) && o.runnable.external_reports }
      .flat_map{ |o| o.runnable.external_reports }
      .select{ |r| r.report_type == "class" }
      .uniq{ |r| r.id }
      .sort{ |r1, r2| r1.launch_text <=> r2.launch_text }
  end

  def update_report_model_cache
    self.offerings.each do |offering|
      offering.learners.each do |learner|
        learner.update_report_model_cache()
      end
    end
  end
end
