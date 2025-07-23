#
# A Portal::Offering represents a material assigned to a class.
#
# - The runnable_type and runnable_id point to the material type and
# material id of the material assigned.
# - The clazz_id points to the class to which the material was assigned.
#
class Portal::Offering < ApplicationRecord
  self.table_name = :portal_offerings

  acts_as_replicatable

  # in Rails 5 instead of returning false to terminate the chain you throw :abort
  before_destroy :throw_abort_if_cant_be_deleted

  belongs_to :clazz, :class_name => "Portal::Clazz", :foreign_key => "clazz_id"
  belongs_to :runnable, :polymorphic => true, :counter_cache => "offerings_count"

  has_many :learners, :dependent => :destroy, :class_name => "Portal::Learner", :foreign_key => "offering_id",
    :inverse_of => :offering

  has_many :teacher_full_status, :dependent => :destroy, :class_name => "Portal::TeacherFullStatus", :foreign_key => "offering_id"

  has_many :collaborations, :class_name => "Portal::Collaboration"

  [:name, :short_description, :long_description, :long_description_for_teacher, :icon_image].each { |m| delegate m, :to => :runnable }

  # create one of these on the fly as needed
  def report_embeddable_filter
    super || create_report_embeddable_filter(:embeddables => [])
  end

  def find_or_create_learner(student)
    learners.find_by_student_id(student) || learners.create(:student_id => student.id)
  end

  def external_activity?
    self.runnable.is_a? ExternalActivity
  end

  self.extend SearchableModel

  @@searchable_attributes = %w{status}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

  end

  def active?(current_user = nil)
    active = self.active
    if current_user
      metadata = UserOfferingMetadata.find_by(user_id: current_user.id, offering_id: self.id)
      if metadata.present?
        active = metadata.active
      end
    end
    active
  end

  def activate
    self.active = true
  end

  def activate!
    self.activate
    self.save
  end

  def deactivate
    self.active = false
  end

  def deactivate!
    self.deactivate
    self.save
  end

  def archived?
    runnable.archived?
  end

  def should_show?(current_user = nil)
    active?(current_user) && (!archived?)
  end

  def can_be_deleted?
    learners.empty?
  end

  def throw_abort_if_cant_be_deleted
    if !can_be_deleted?
      throw(:abort)
    end
  end

  def run_format
    runnable.run_format
  end

  def has_default_report?
    DefaultReportService::default_report_for_offering(self) != nil
  end

  def reportable?
    has_default_report?
  end

  def individual_student_reportable?
    report = DefaultReportService::default_report_for_offering(self)
    report && report.individual_student_reportable
  end

  def individual_activity_reportable?
    report = DefaultReportService::default_report_for_offering(self)
    report && report.individual_activity_reportable
  end

  def student_report_enabled?
    if runnable.respond_to? :student_report_enabled
      runnable.student_report_enabled
    else
      # by default this is true
      true
    end
  end

  def self.find_all_using_runnable_id_and_runnable_type_and_default_offering(id, type, default)
    where(runnable_id: id, runnable_type: type, default_offering: default)
  end

  def completed_students_count
    student_ids = self.clazz.students.map{|item| item.id}
    learners = self.learners.select{|item| student_ids.include?(item.student_id)}
    learners_completed = learners.select {|item|!item.report_learner.nil? && item.report_learner.complete_percent == 100}
    num_completed = 0
    num_completed = learners_completed.count
    num_completed
  end

  def inprogress_students_count
    student_ids = self.clazz.students.map{|item| item.id}
    learners = self.learners.select{|item| student_ids.include?(item.student_id)}
    learners_in_progress = learners.select {|item| !item.report_learner.nil? && !item.report_learner.complete_percent.nil? && item.report_learner.complete_percent > 0 &&  item.report_learner.complete_percent < 100}
    num_in_progress = 0
    num_in_progress = learners_in_progress.length
    num_in_progress
  end

  def notstarted_students_count
    num_not_started = 0
    num_not_started = self.clazz.students.length - (completed_students_count + inprogress_students_count)
  end
end
