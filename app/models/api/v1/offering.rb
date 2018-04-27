class API::V1::Offering
  include Rails.application.routes.url_helpers
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
      learner = offering.learners.find { |l| l.student_id === student.id }
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
  attribute :report_url, String
  attribute :external_report, Hash
  attribute :students, Array[OfferingStudent]

  def initialize(offering, protocol, host_with_port)
    runnable = offering.runnable
    self.id = offering.id
    self.teacher = offering.clazz.teacher.name
    self.clazz = offering.clazz.name
    self.clazz_id = offering.clazz.id
    self.clazz_info_url = offering.clazz.class_info_url(protocol, host_with_port)
    self.activity = offering.name
    self.activity_url = runnable.respond_to?(:url) ? runnable.url : nil
    self.report_url = offering.reportable? ? report_portal_offering_url(id: offering.id, protocol: protocol, host: host_with_port) : nil
    if runnable.respond_to?(:external_report) && runnable.external_report
      self.external_report =  {
        id: runnable.external_report.id,
        name: runnable.external_report.name,
        url: portal_external_report_url(id: offering.id, report_id: runnable.external_report.id, protocol: protocol, host: host_with_port),
        launch_text: runnable.external_report.launch_text
      }
    else
      self.external_report = nil
    end
    self.students = offering.clazz.students.map { |s| OfferingStudent.new(s, offering) }
  end
end
