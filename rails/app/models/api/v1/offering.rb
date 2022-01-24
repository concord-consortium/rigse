class API::V1::Offering
  include Rails.application.routes.url_helpers
  include Virtus.model
  include RunnablesHelper

  # Optimize SQL queries based on API::V1::Offering structure.
  INCLUDES_DEF = {
      # It's questionable whether :learner_activity_feedbacks should be loaded eagerly. There are multiple instances
      # of learner activity feedback per given learner, but this API is interested only in the most recent one.
      # Eager loading will load all of them, though. Another option would be to remove it and use following query:
      # Portal::LearnerActivityFeedback.for_learner_and_activity_feedback(learner.id, activity_feedback.id).first
      # It loads only one feedback per learner, but will require N separate queries (1 per learner).
      # I feel that eager loading (single SQL query) should be faster anyway, as in most cases there shouldn't
      # be too many separate feedback objects for given learner. A new one is created when teacher first marks feedback
      # as completed, and then updates it later again.
      activity_feedbacks: :learner_activity_feedbacks,
      learners: [:report_learner, {learner_activities: :activity, student: :user}],
      clazz: {students: :user}
      # TODO when we only support external activity runnables then the following
      # line can be used to optimize the database requests
      # runnable: [:template, :external_report]
  }

  class OfferingStudent
    include Rails.application.routes.url_helpers
    include Virtus.model

    attribute :name, String
    attribute :first_name, String
    attribute :last_name, String
    attribute :username, String
    attribute :user_id, Integer
    attribute :started_activity, Boolean
    attribute :endpoint_url, String
    attribute :learner_report_url, String
    attribute :last_run, Date
    attribute :total_progress, Float
    attribute :detailed_progress, Array

    def initialize(student, offering, activity_feedbacks, protocol, host_with_port)
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
      self.learner_report_url = learner && learner.reportable? ? report_portal_learner_url(learner, protocol: protocol, host: host_with_port) : nil
      if learner && learner.learner_activities.count > 0
        self.detailed_progress = learner.learner_activities.map do |la|
          {
              activity_id: la.activity.id,
              activity_name: la.activity.name,
              progress: la.complete_percent,
              learner_activity_report_url: learner.reportable? ? portal_learners_report_url(learner, la.activity, protocol: protocol, host: host_with_port) : nil,
              feedback: feedback_json(learner, activity_feedbacks[la.activity.id])
          }
        end
      end
    end

    def feedback_json(learner, activity_feedback)
      # Use .find instead of SQL queries to take benefit of eager loading. See notes above whether it's the best idea
      # or not. Another option would be:
      # learner_feedback = Portal::LearnerActivityFeedback.for_learner_and_activity_feedback(learner.id, activity_feedback.id).first
      learner_feedback = activity_feedback && activity_feedback.learner_activity_feedbacks.find { |laf| laf.portal_learner_id === learner.id }
      return nil unless learner_feedback
      {
          has_been_reviewed: learner_feedback.has_been_reviewed,
          score: learner_feedback.score,
          text_feedback: learner_feedback.text_feedback,
          rubric_feedback: learner_feedback.rubric_feedback
      }
    end
  end

  attribute :id, Integer
  attribute :teacher, String
  attribute :clazz, String
  attribute :clazz_hash, String
  attribute :clazz_id, Integer
  attribute :clazz_info_url, String
  attribute :clazz_is_archived, Boolean
  attribute :activity, String
  attribute :activity_url, String
  attribute :material_type, String
  attribute :report_url, String
  attribute :rubric_url, String
  attribute :preview_url, String
  attribute :has_teacher_edition, Boolean
  # 2019-07-16 NP:  TODO: deprecate `external_report` in favor of `external_reports`
  attribute :external_report, Hash
  attribute :external_reports, Array
  attribute :reportable, Boolean
  attribute :reportable_activities, Array
  attribute :students, Array[OfferingStudent]

  def report_attributes(report, offering, protocol, host_with_port)
    {
      id: report.id,
      name: report.name,
      url: portal_external_report_url(id: offering.id, report_id: report.id, protocol: protocol, host: host_with_port),
      launch_text: report.launch_text
    }
  end

  def initialize(offering, protocol, host_with_port, current_user, additional_external_report_id)
    runnable = offering.runnable
    self.id = offering.id
    self.teacher = offering.clazz.teacher.name
    self.clazz = offering.clazz.name
    self.clazz_hash = offering.clazz.class_hash
    self.clazz_id = offering.clazz.id
    self.clazz_info_url = offering.clazz.class_info_url(protocol, host_with_port)
    self.clazz_is_archived = offering.clazz.is_archived
    self.activity = offering.name
    self.activity_url = runnable.respond_to?(:url) ? runnable.url : nil
    self.material_type = runnable.material_type
    self.has_teacher_edition = runnable.has_teacher_edition
    self.reportable = offering.reportable?
    self.rubric_url = runnable.respond_to?(:rubric_url) ? runnable.rubric_url : nil
    self.report_url = offering.reportable? ? report_portal_offering_url(id: offering.id, protocol: protocol, host: host_with_port) : nil
    self.preview_url = run_url_for(runnable, preview_params(current_user, {protocol: protocol, host: host_with_port}))
    # 2019-07-16 NP:  TODO: deprecate `external_report` in favor of `external_reports`
    if runnable.respond_to?(:external_report) && runnable.external_report
      self.external_report = report_attributes(runnable.external_report, offering, protocol, host_with_port)
    end
    self.external_reports = []
    if runnable.respond_to?(:external_reports) && runnable.external_reports
      runnable.external_reports.each do |report|
        self.external_reports << report_attributes(report, offering, protocol, host_with_port)
      end
    end
    if additional_external_report_id
      additional_report = ExternalReport.find_by_id(additional_external_report_id)
      if additional_report
        self.external_reports << report_attributes(additional_report, offering, protocol, host_with_port)
      end
    end

    # Cache feedback activity objects and pass them to student model.
    activity_feedbacks = {}
    if offering.reportable?
      # This section is probably used internally by Portal Pages to render progress bars and feedback info.
      self.reportable_activities = (runnable.respond_to?(:activities) && runnable.activities || [ runnable ]).map do |activity|
        if activity.respond_to?(:template) && activity.template
          # Use template model for reporting purposes when we're dealing with ExternalActivity.
          # That's the general assumption in many other places. Reporting code and URL helpers expect template object ID.
          activity = activity.template
        end
        activity_feedback = offering.activity_feedbacks.find { |af| af.activity_id == activity.id }
        activity_feedbacks[activity.id] = activity_feedback
        {
            id: activity.id,
            name: activity.name,
            type: activity.class.to_s,
            activity_report_url: offering.individual_activity_reportable? ? portal_offerings_report_url(offering, activity, protocol: protocol, host: host_with_port) : nil,
            feedback_options: activity_feedback && {
                score_feedback_enabled: !!activity_feedback.enable_score_feedback,
                text_feedback_enabled: !!activity_feedback.enable_text_feedback,
                rubric_feedback_enabled: !!activity_feedback.use_rubric,
                score_type: activity_feedback.score_type,
                max_score: activity_feedback.max_score,
                rubric_url: activity_feedback.rubric_url,
                rubric: activity_feedback.rubric
            }
        }
      end
    end
    self.students = offering.clazz.students.map { |s| OfferingStudent.new(s, offering, activity_feedbacks, protocol, host_with_port) }
  end
end
