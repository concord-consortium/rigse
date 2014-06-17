#
# This is a denormalized class. Its used to store summary data for
# learners as would be used in a report.

class Report::Learner < ActiveRecord::Base
  self.table_name = "report_learners"

  belongs_to   :learner, :class_name => "Portal::Learner", :foreign_key => "learner_id"
  serialize    :answers, Hash
  belongs_to   :runnable, :polymorphic => true

  scope :after,  lambda         { |date|         {:conditions => ["last_run > ?", date]} }
  scope :before, lambda         { |date|         {:conditions => ["last_run < ?", date]} }
  scope :in_schools, lambda     { |school_ids|   {:conditions => {:school_id   => school_ids   }}}
  scope :in_classes, lambda     { |class_ids|    {:conditions => {:class_id    => class_ids    }}}
  scope :with_perm_form, lambda { |perm_forms|
    query = perm_forms.map { |pf| "find_in_set(?,permission_forms)" }.join(" or ")
    where("(#{query})", *perm_forms)
  }
  scope :with_runnables, lambda { |runnables|
    where 'CONCAT(runnable_type, "_", runnable_id) IN (?)', runnables.map{|runnable| "#{runnable.class}_#{runnable.id}"}.join(",")}

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
      hash = {:answer => s.answer, :answered => s.answered?, :submitted => s.submitted?, :question_required => s.embeddable.is_required }
      hash[:is_correct] = s.answered_correctly? if s.respond_to?("answered_correctly?")
      if hash[:answer].is_a? Hash
        if hash[:answer][:blob]
          blob = hash[:answer][:blob]
          hash[:answer] = {
            :type => "Dataservice::Blob",
            :id => blob.id,
            :token => blob.token,
            :file_extension => blob.file_extension,
            :note => hash[:answer][:note]
          }
        end
      end
      answers_hash["#{s.embeddable.class.to_s}|#{s.embeddable.id}"] = hash
    end
    self.answers = answers_hash
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
    update_field("offering.clazz.teachers", "teachers_name") do |ts|
      ts.map{ |t| t.user.name}.join(", ")
    end

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
      self.complete_percent = 99.9
      self.last_run = Time.now
    end
    Rails.logger.debug("Updated Report Learner: #{self.student_name}")
    self.save
  end

  def update_permission_forms
    update_field("student.permission_forms", "permission_forms") do |pfs|
      pfs.map{ |p| p.name }.join(",")
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
