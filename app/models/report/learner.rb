#
# This is a denormalized class. Its used to store summary data for
# learners as would be used in a report.

class Report::Learner < ActiveRecord::Base
  self.table_name = "report_learners"

  belongs_to   :learner, :class_name => "Portal::Learner", :foreign_key => "learner_id",
    :inverse_of => :report_learner
  belongs_to   :student, :class_name => "Portal::Student"
  serialize    :answers, Hash
  belongs_to   :runnable, :polymorphic => true

  scope :after,  lambda         { |date|         {:conditions => ["last_run > ?", date]} }
  scope :before, lambda         { |date|         {:conditions => ["last_run < ?", date]} }
  scope :in_schools, lambda     { |school_ids|   {:conditions => {:school_id   => school_ids   }}}
  scope :in_classes, lambda     { |class_ids|    {:conditions => {:class_id    => class_ids    }}}

  scope :with_permission_ids, lambda { |ids|
    includes(student: :portal_student_permission_forms)
      .where("portal_student_permission_forms.portal_permission_form_id" => ids)

  }

  scope :with_runnables, lambda { |runnables|
    where 'CONCAT(runnable_type, "_", runnable_id) IN (?)', runnables.map{|runnable| "#{runnable.class}_#{runnable.id}"}}

  validates_presence_of   :learner
  validates_uniqueness_of :learner_id

  after_create :update_fields
  before_save :ensure_no_nils

  def ensure_no_nils
    %w{offering_name teachers_name student_name class_name school_name runnable_name}.each do |attr|
      cur_val = self.send(attr)
      self.send("#{attr}=", "") if cur_val.nil?
    end
    return true
  end

  def serialize_blob_answer(answer)
    if answer.is_a? Hash
      blob = answer[:blob]
      if blob
        # Return a serialized hash of the blob
        return {
            :type => "Dataservice::Blob",
            :id => blob.id,
            :token => blob.token,
            :file_extension => blob.file_extension,
            :note => answer[:note]
        }
      end
    end
    # Otherwise don't change it
    return answer
  end

  def last_run_string(opts={})
    return Report::Learner.build_last_run_string(last_run, opts)
  end

  def self.build_last_run_string(last_run, opts={})
    not_run_str = "not yet started" || opts[:not_run]
    prefix      = "Last run"        || opts[:prefix]
    format      = "%b %d, %Y"       || opts[:format]

    return not_run_str if !last_run
    return "#{prefix} #{last_run.strftime(format)}"
  end

  def calculate_last_run
    bundle_logger = self.learner.bundle_logger
    pub_logger = self.learner.periodic_bundle_logger
    bucket_logger = self.learner.bucket_logger
    bundle_time = nil
    pub_time = nil
    bucket_time = nil

    if bundle_logger && bundle_logger.last_non_empty_bundle_content
      bundle_time = bundle_logger.last_non_empty_bundle_content.updated_at
    end

    if pub_logger && pub_logger.periodic_bundle_contents.last
      pub_time =pub_logger.periodic_bundle_contents.last.updated_at
    end

    if bucket_logger && bucket_logger.bucket_contents.last
      bucket_time = bucket_logger.bucket_contents.last.updated_at
    end

    times = [pub_time,bundle_time,bucket_time].compact.sort
    if times.size > 0
      self.last_run = times.last
    end

  end

  def update_answers
    report_util = Report::UtilLearner.new(self.learner)

    # We need to populate these field
    self.num_answerables = report_util.embeddables.size
    self.num_answered = report_util.saveables.count { |s| s.answered? }
    self.num_submitted = report_util.saveables.count { |s| s.submitted? }
    self.num_correct = report_util.saveables.count { |s|
      (s.respond_to? 'answered_correctly?') ? s.answered_correctly? : false
    }
    self.complete_percent = report_util.complete_percent

    update_activity_completion_status(report_util)

    # We might also want to gather 'saveables' in An associated model?
    # AU: We'll use a serialized column to store a hash, for now
    answers_hash = {}
    report_util.saveables.each do |s|
      # feedbacks = s.answers.map do |ans|
      # TOOD: Eventually we want all answers.... Or answers with feedback...
      # this has been simplified here because for performance reasons.
      feedbacks = [s.answers.last].compact.map do |ans|
        {
            answer: serialize_blob_answer(ans.answer),
            answer_key: Report::Learner.encode_answer_key(ans),
            score: ans.respond_to?(:score) ? ans.score  : nil,
            feedback: ans.respond_to?(:feedback) ? ans.feedback : nil,
            has_been_reviewed: ans.respond_to?(:has_been_reviewed?) ? (ans.has_been_reviewed?||false) : nil
        }
      end
      hash = {
          answer: serialize_blob_answer(s.answer),
          answer_type: s.answer_type,
          feedbacks: feedbacks,
          answered: s.answered?,
          submitted: s.submitted?,
          question_required: s.embeddable.is_required
      }
      if s.respond_to?("has_correct_answer?") && s.has_correct_answer? && s.respond_to?("answered_correctly?")
        hash[:is_correct] = s.answered_correctly?
      end
      answers_hash[ Report::Learner.encode_answer_key(s.embeddable)] = hash
    end
    self.answers = answers_hash
  end

  def self.encode_answer_key(item)
    "#{item.class.to_s}|#{item.id}"
  end

  def self.decode_answer_key(answer_key)
    answer_key.split("|")
  end

  def update_field(methods_string, field=nil)
    value = nil
    unless field
      field =methods_string.split(".")[-2..2].join("_")
    end
    begin
      symbols = methods_string.split(".").map{ |s| s.to_sym}
      value = symbols.inject(self.learner) do |o,symbol|
        o.send(symbol)
      end
      if block_given?
        value = yield(value)
      end
      self.send("#{field}=".to_sym,value)
    rescue
      Rails.logger.error("could not set self.#{field} using self.learner.#{methods_string} #{$!}!")
    end
  end

  def update_fields
    update_field "student.id"
    update_field "offering.id"
    update_field "offering.name"

    update_field "offering.runnable.name"
    update_field "offering.runnable.id"
    update_field "offering.runnable.class.to_s", "runnable_type"

    update_field "student.user.id"
    update_field "student.user.name", "student_name"
    update_field "student.user.login", "username"

    update_field "offering.clazz.id", "class_id"
    update_field "offering.clazz.name", "class_name"
    update_field "offering.clazz.school.name", "school_name"
    update_field "offering.clazz.school.id",    "school_id"

    update_teacher_info_fields

    update_permission_forms

    # check to see if we can obtain the last run info
    if self.learner.offering.internal_report?
      calculate_last_run
      update_answers
    else
      self.num_answerables = 0
      self.num_answered = 0
      self.num_submitted = 0
      self.num_correct = 0
      # Offering is not reportable, so return 100% progress, as it's been started. That's the only information available.
      self.complete_percent = 100
      self.last_run = Time.now
    end
    Rails.logger.debug("Updated Report Learner: #{self.student_name}")
    self.save
  end

  def escape_comma(string)
    string.gsub(',', ' ')
  end

  def update_teacher_info_fields
    update_field("offering.clazz.teachers", "teachers_name") do |ts|
      ts.map{ |t| escape_comma(t.user.name) }.join(", ")
    end
    update_field("offering.clazz.teachers", "teachers_district") do |ts|
      ts.map{ |t| t.schools.map{ |s| escape_comma(s.district.name)}.join(", ")}.join(", ")
    end
    update_field("offering.clazz.teachers", "teachers_state") do |ts|
      ts.map{ |t| t.schools.map{ |s| escape_comma(s.district.state)}.join(", ")}.join(", ")
    end
    update_field("offering.clazz.teachers", "teachers_email") do |ts|
      ts.map{ |t| escape_comma(t.user.email)}.join(", ")
    end
    update_field("offering.clazz.teachers", "teachers_id") do |ts|
      ts.map{ |t| t.id}.join(", ")
    end
    update_field("offering.clazz.teachers", "teachers_map") do |ts|
      ts.map{ |t| "#{t.id}: #{escape_comma(t.user.name)}"}.join(", ")
    end

  end

  def update_permission_forms
    update_field("student.permission_forms", "permission_forms") do |pfs|
      pfs.map{ |p| escape_comma(p.fullname) }.join(",")
    end
    update_field("student.permission_forms", "permission_forms_id") do |pfs|
      pfs.map{ |p| p.id }.join(",")
    end
    update_field("student.permission_forms", "permission_forms_map") do |pfs|
      pfs.map{ |p| "#{p.id}: #{escape_comma(p.fullname)}" }.join(",")
    end
  end

  def update_activity_completion_status(report_util)
    offering = self.learner.offering
    assignable = offering.runnable
    if assignable.is_a?(::ExternalActivity) && assignable.template
      assignable = assignable.template
    end

    activities = []
    if assignable.is_a? ::Investigation
      activities = assignable.activities
    elsif assignable.is_a? ::Activity
      activities = [assignable]
    end

    activities.each do|activity|
      complete_percent = report_util.complete_percent(activity)
      report_learner_activity = Report::LearnerActivity.find_or_create_by_learner_id_and_activity_id(self.learner.id, activity.id)
      report_learner_activity.complete_percent = complete_percent
      report_learner_activity.save!
    end
  end

end
