class Portal::Offering < ActiveRecord::Base
  self.table_name = :portal_offerings

  acts_as_replicatable

  belongs_to :clazz, :class_name => "Portal::Clazz", :foreign_key => "clazz_id"
  belongs_to :runnable, :polymorphic => true, :counter_cache => "offerings_count"

  has_many :learners, :dependent => :destroy, :class_name => "Portal::Learner", :foreign_key => "offering_id"

  has_one :report_embeddable_filter, :dependent => :destroy, :class_name => "Report::EmbeddableFilter", :foreign_key => "offering_id"

  has_many :teacher_full_status, :dependent => :destroy, :class_name => "Portal::TeacherFullStatus", :foreign_key => "offering_id"

  [:name, :description].each { |m| delegate m, :to => :runnable }

  has_many :open_responses, :class_name => "Saveable::OpenResponse", :foreign_key => "offering_id" do
    def answered
      find(:all).select { |question| question.answered? }
    end
  end

  has_many :multiple_choices, :class_name => "Saveable::MultipleChoice", :foreign_key => "offering_id" do
    def answered
      find(:all).select { |question| question.answered? }
    end
    def answered_correctly
      find(:all).select { |question| question.answered? }.select{ |item| item.answered_correctly? }
    end
  end

  attr_reader :saveable_objects
  before_destroy :can_be_deleted?

  def sessions
    self.learners.inject(0) { |sum, l| sum + l.sessions }
  end

  def find_or_create_learner(student)
    learners.find_by_student_id(student) || learners.create(:student_id => student.id)
  end

  def saveables
    multiple_choices + open_responses
  end

  def resource_page?
    self.runnable.is_a? ResourcePage
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

  def can_be_deleted?
    learners.empty?
  end

  def run_format
    runnable.run_format
  end
  
  def internal_report?
    klass = runnable.class

    # handle ExernalActivities that are backed by a reportable template
    if klass == ExternalActivity
      if runnable.template
        klass = runnable.template.class
      end
    end

    return [Investigation, Activity, Page].include? klass    
  end

  def reportable?
    if internal_report?
      true
    else
      runnable.class == ExternalActivity && !runnable.report_url.blank?
    end
  end

  def individual_reportable?
    internal_report?
  end

  def printable_report?
    internal_report?
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
    learners_in_progress = learners.select {|item| !item.report_learner.nil? && item.report_learner.complete_percent > 0 &&  item.report_learner.complete_percent < 100}
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
