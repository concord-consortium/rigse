class API::V1::Offering
  include Virtus.model

  class OfferingStudent
    include Virtus.model
    attribute :name, String
    attribute :first_name, String
    attribute :last_name, String
    attribute :username, String
    attribute :user_id, Integer
    attribute :started_activity, Boolean
    attribute :endpoint_url, String
    attribute :last_run, Date
    attribute :total_progress, Float
    attribute :detailed_progress, Array

    def initialize(student, offering)
      self.name = student.user.name
      self.first_name = student.user.first_name
      self.last_name = student.user.last_name
      self.username = student.user.login
      self.user_id = student.user.id
      learner = offering.learners.where(student_id: student.id).first
      # Learner object is available only if student has started the activity.
      self.started_activity = learner ? true : false
      self.endpoint_url = learner ? learner.remote_endpoint_url : nil
      self.total_progress = learner ? learner.report_learner.complete_percent : 0
      self.last_run = learner ? learner.report_learner.last_run : nil
      if learner
        self.detailed_progress = learner.learner_activities.map do |la|
          { activity: la.activity.name, progress: la.complete_percent }
        end
      end
    end
  end

  attribute :id, Integer
  attribute :teacher, String
  attribute :clazz, String
  attribute :clazz_id, Integer
  attribute :clazz_info_url, String
  attribute :activity, String
  attribute :activity_url, String
  attribute :students, Array[OfferingStudent]

  def initialize(offering, protocol, host_with_port)
    self.id = offering.id
    self.teacher = offering.clazz.teacher.name
    self.clazz = offering.clazz.name
    self.clazz_id = offering.clazz.id
    self.clazz_info_url = offering.clazz.class_info_url(protocol, host_with_port)
    self.activity = offering.name
    self.activity_url = offering.runnable.respond_to?(:url) ? offering.runnable.url : nil
    self.students = offering.clazz.students.map { |s| OfferingStudent.new(s, offering) }
  end
end
