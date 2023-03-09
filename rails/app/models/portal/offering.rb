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

  has_one :report_embeddable_filter, :dependent => :destroy, :class_name => "Report::EmbeddableFilter", :foreign_key => "offering_id"

  has_many :teacher_full_status, :dependent => :destroy, :class_name => "Portal::TeacherFullStatus", :foreign_key => "offering_id"

  has_many :collaborations, :class_name => "Portal::Collaboration"

  has_many :activity_feedbacks, class_name: "Portal::OfferingActivityFeedback", foreign_key: "portal_offering_id"

  [:name, :short_description, :long_description, :long_description_for_teacher, :icon_image].each { |m| delegate m, :to => :runnable }

  has_many :open_responses, :dependent => :destroy, :class_name => "Saveable::OpenResponse", :foreign_key => "offering_id" do
    def answered
      where({ answered: true })
    end
  end

  has_many :multiple_choices, :dependent => :destroy, :class_name => "Saveable::MultipleChoice", :foreign_key => "offering_id" do
    def answered
      where({ answered: true })
    end

    def answered_correctly
      # all.select { |question| question.answered? }.select{ |item| item.answered_correctly? }
      where({ answered: true, answered_correctly: true })
    end
  end

  has_many :metadata, :class_name => "Portal::OfferingEmbeddableMetadata" do
    def for_embeddable(embeddable)
      where(embeddable_type: embeddable.class.name, embeddable_id: embeddable.id).first
    end
  end

  attr_reader :saveable_objects

  # create one of these on the fly as needed
  def report_embeddable_filter
    super || create_report_embeddable_filter(:embeddables => [])
  end

  def find_or_create_learner(student)
    learners.find_by_student_id(student) || learners.create(:student_id => student.id)
  end

  def saveables
    multiple_choices + open_responses
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

  def refresh_saveable_response_objects
    self.learners.each { |l| l.refresh_saveable_response_objects }
  end


  def active?
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

  def should_show?
    active? && (!archived?)
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
  # def saveable_count
  #   @saveable_count ||= begin
  #     runnable = self.runnable
  #     @saveable_objects = {}
  #     runnable.saveable_types.inject(0) do |count, @saveable_object|
  #       saveable_association = saveable_class.to_s.demodulize.tableize
  #       @saveable_objects[@saveable_object] = runnable.send(saveable_association)
  #       count + @saveable_objects[@saveable_object].length
  #     end
  #   end
  # end
  #
  # def saveable_objects
  #   @saveable_objects || begin
  #     saveable_count
  #     @saveable_objects
  #   end
  # end
  #
  # def saveable_answered
  #   @saveable_answered ||= begin
  #     saveable_objects
  #     runnable = self.offering.runnable
  #     runnable.saveable_types.inject(0) do |count, saveable_class|
  #       saveable_association = saveable_class.to_s.demodulize.tableize
  #       count + self.send(saveable_association).send(:answered).length
  #     end
  # end

end
