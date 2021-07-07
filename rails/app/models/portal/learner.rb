class Portal::Learner < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  self.table_name = :portal_learners

  default_scope { order('portal_learners.student_id ASC') }

  acts_as_replicatable

  belongs_to :student, :class_name => "Portal::Student", :foreign_key => "student_id"
  belongs_to :offering, :class_name => "Portal::Offering", :foreign_key => "offering_id",
    :inverse_of => :learners

  belongs_to :console_logger, :class_name => "Dataservice::ConsoleLogger", :foreign_key => "console_logger_id", :dependent => :destroy
  belongs_to :bundle_logger, :class_name => "Dataservice::BundleLogger", :foreign_key => "bundle_logger_id", :dependent => :destroy
  has_one    :periodic_bundle_logger, :class_name => "Dataservice::PeriodicBundleLogger", :foreign_key => "learner_id", :dependent => :destroy
  has_one    :bucket_logger, :class_name => "Dataservice::BucketLogger", :foreign_key => "learner_id", :dependent => :destroy

  has_many :open_responses, :dependent => :destroy , :class_name => "Saveable::OpenResponse" do
    def answered
      all.select { |question| question.answered? }
    end
  end

  has_many :learner_activities, :dependent => :destroy , :class_name => "Report::LearnerActivity"

  has_many :image_questions, :dependent => :destroy, :class_name => "Saveable::ImageQuestion" do
    def answered
      all.select { |question| question.answered? }
    end
  end

  has_many :multiple_choices, :dependent => :destroy, :class_name => "Saveable::MultipleChoice" do
    def answered
      all.select { |question| question.answered? }
    end
    def answered_correctly
      all.select { |question| question.answered? }.select{ |item| item.answered_correctly? }
    end
  end

  has_many :external_links, :dependent => :destroy , :class_name => "Saveable::ExternalLink" do
    def answered
      all.select { |question| question.answered? }
    end
  end

  has_many :interactives, :dependent => :destroy , :class_name => "Saveable::Interactive" do
    def answered
      all.select { |question| question.answered? }
    end
  end

  has_one :report_learner, :dependent => :destroy, :class_name => "Report::Learner",
    :foreign_key => "learner_id", :inverse_of => :learner

  has_many :lightweight_blobs, :dependent => :destroy, :class_name => "Dataservice::Blob"

  default_value_for :secure_key do
    UUIDTools::UUID.random_create.to_s
  end

  # automatically make the report learner if it doesn't exist yet
  def report_learner
    # I'm using the ! here so we can track down errors faster if there is an issue making
    # the report_learner
    super || create_report_learner!
  end

  def sessions
    self.bundle_logger.bundle_contents.length
  end

  [:name, :first_name, :last_name, :email].each { |m| delegate m, :to => :student }

  before_create do |learner|
    learner.create_console_logger
    learner.create_bundle_logger
  end

  after_create do |learner|
    # have to create this after so that the learner id can be stored in the new bundle logger
    learner.create_periodic_bundle_logger
    learner.update_report_model_cache
  end

  def valid_loggers?
    console_logger && bundle_logger && periodic_bundle_logger
  end

  def create_new_loggers
    create_console_logger
    create_bundle_logger
    create_periodic_bundle_logger
  end

  # validates_presence_of :console_logger, :message => "console_logger association not specified"
  # validates_presence_of :bundle_logger,  :message => "bundle_logger association not specified"

  validates_presence_of :student,  :message => "student association not specified"
  validates_presence_of :offering, :message => "offering association not specified"

  #
  # before_save do |learner|
  #   learner.console_logger = Dataservice::ConsoleLogger.create! unless learner.console_logger
  #   learner.bundle_logger = Dataservice::BundleLogger.create! unless learner.bundle_logger
  # end

  include Changeable

  # pagination default
  cattr_reader :per_page
  @@per_page = 10

  self.extend SearchableModel

  @@searchable_attributes = %w{updated_at}

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    def find_by_id_or_key(id_or_key)
      if /\A\d+\z/.match(id_or_key)
        # if the key is just digits then it could be either a id or secure_key
        Portal::Learner.where('secure_key = ? OR id = ?', id_or_key, id_or_key).first!
      else
        # If the key has non numbers, then it has to be a secure_key.
        # This check is necessary because SQL will convert a string like 68abcd to 68 when
        # comparing with an integer. Therefore, if the query above is always used then
        # 68abcd will match a secure_key of 68abcd but it will also match the id 68
        Portal::Learner.where('secure_key = ?', id_or_key).first!
      end
    end

  end

  # for the view system ...
  def user
    student.user
  end

  def name
    user = student.user.name
    # name = user.name
    # login = user.login
    # runnable_name = (offering ? offering.runnable.name : "invalid offering runnable")
    # "#{user.login}: (#{user.name}), #{runnable_name}, #{self.bundle_logger.bundle_contents.count} sessions"
  end

  def saveable_count
    runnable = self.offering.runnable
    runnable = runnable.template if runnable.is_a?(ExternalActivity) && runnable.template
    runnable.saveable_types.inject(0) do |count, saveable_class|
      saveable_association = saveable_class.to_s.demodulize.tableize
      count + self.send(saveable_association).length
    end
  end

  def saveable_answered
    runnable = self.offering.runnable
    runnable = runnable.template if runnable.is_a?(ExternalActivity) && runnable.template
    runnable.saveable_types.inject(0) do |count, saveable_class|
      saveable_association = saveable_class.to_s.demodulize.tableize
      count + self.send(saveable_association).send(:answered).length
    end
  end

  def refresh_saveable_response_objects
    # runnable = self.offering.runnable
    # runnable = runnable.template if runnable.is_a?(ExternalActivity) && runnable.template
    # runnable.saveable_types.each do |saveable_class|
    #   saveable_association = saveable_class.to_s.demodulize.tableize
    #   saveable_id_symbol = "#{saveable_association.singularize}_id".to_sym
    #   saveable_objects = runnable.send(saveable_association)
    #   saved_objects = self.send(saveable_association)
    #   existing_saveable_ids = saved_objects.collect { |o| o.send(saveable_id_symbol) }
    #   unsaved_objects = saveable_objects.find_all { |o| !existing_saveable_ids.include?(o.id) }
    #   unsaved_objects.each do |unsaved_object|
    #     saveable_class.create(saveable_id_symbol => unsaved_object.id, :learner_id => self.id)
    #   end
    # end
  end

  def run_format
    offering.runnable.run_format
  end

  def reportable?
    offering.individual_student_reportable?
  end

  def remote_endpoint_path
    if secure_key.present?
      external_activity_return_path(secure_key)
    else
      external_activity_return_path(id)
    end
  end

  def remote_endpoint_url
    if secure_key.present?
      "#{APP_CONFIG[:site_url]}#{external_activity_return_path(secure_key)}"
    else
      "#{APP_CONFIG[:site_url]}#{external_activity_return_path(id)}"
    end
  end

  def update_report_model_cache(skip_report_learner_update = false)
    unless (skip_report_learner_update)
      # We need to keep this in for now, to keep the ReportLearner up-to-date for the built-in reports.
      # update_fields also updates the activity completion status as a side-effect, something that would
      # be easy to re-add here if/when we remove ReportLearners
      self.report_learner.update_fields
    end

    # mostly to stop spec tests from failing
    unless (self.student && self.student.user && self.offering && self.offering.clazz && self.offering.clazz.teachers)
      return
    end

    if !ENV['ELASTICSEARCH_URL']
      return error("Elasticsearch endpoint url not set")
    end

    update_url = "#{ENV['ELASTICSEARCH_URL']}/report_learners/doc/#{self.id}/_update"

    # try to update learner document in ES. We may throw an error trying to get a field, so wrap this in begin/rescue
    begin
      # check to see if we can obtain the last run info
      if self.offering.internal_report?
        last_run = calculate_last_run
        answersMeta = update_answers
        num_answerables = answersMeta[:num_answerables]
        num_answered = answersMeta[:num_answered]
        num_submitted = answersMeta[:num_submitted]
        num_correct = answersMeta[:num_correct]
        complete_percent = answersMeta[:complete_percent]
      else
        num_answerables = 0
        num_answered = 0
        num_submitted = 0
        num_correct = 0
        # Offering is not reportable, so return 100% progress, as it's been started. That's the only information available.
        complete_percent = 100
        last_run = Time.now
      end

      elastic_search_learner_model = {
        learner_id: self.id,
        student_id: self.student.id,
        user_id:  self.student.user.id,
        created_at: self.student.user.created_at,
        offering_id: self.offering.id,
        offering_name: self.offering.name,
        class_id: self.offering.clazz.id,
        class_name: self.offering.clazz.name,
        last_run: last_run,
        school_id: self.offering.clazz.school.id,
        school_name: self.offering.clazz.school.name,
        school_name_and_id: "#{self.offering.clazz.school.id}:#{self.offering.clazz.school.name}",
        runnable_id: self.offering.runnable.id,
        runnable_name: self.offering.runnable.name,
        runnable_type: self.offering.runnable.class.to_s.downcase,
        runnable_type_and_id: "#{self.offering.runnable.class.to_s.downcase}_#{self.offering.runnable.id}",
        runnable_type_id_name: "#{self.offering.runnable.class.to_s.downcase}_#{self.offering.runnable.id}:#{self.offering.runnable.name}",
        num_answerables: num_answerables,
        num_answered: num_answered,
        num_submitted: num_submitted,
        num_correct: num_correct,
        complete_percent: complete_percent,
        teachers_id: self.offering.clazz.teachers.map { |t| t.id },
        teachers_name: self.offering.clazz.teachers.map { |t| escape_comma(t.user.name) },
        teachers_district: self.offering.clazz.teachers.map { |t|
          t.schools
           .select{ |s| s.district.present? }
           .map{ |s| escape_comma(s.district.name)}
           .join(", ")
        },
        teachers_state: self.offering.clazz.teachers.map { |t|
          t.schools
           .select{ |s| s.district.present? }
           .map{ |s| escape_comma(s.district.state)}
           .join(", ")
        },
        teachers_email: self.offering.clazz.teachers.map { |t| escape_comma(t.user.email)},
        teachers_map: self.offering.clazz.teachers.map { |t| "#{t.id}: #{escape_comma(t.user.name)}"},
        permission_forms: self.student.permission_forms.map { |p| escape_comma(p.fullname) },
        permission_forms_id: self.student.permission_forms.map { |p| p.id },
        permission_forms_map: self.student.permission_forms.map{ |p| "#{p.id}: #{escape_comma(p.fullname)}" }
      }

      # doc_as_upsert means update if exists, create if it doesn't
      HTTParty.post(update_url,
        :body => {
          :doc => elastic_search_learner_model,
          :doc_as_upsert => true
        }.to_json,
        :headers => { 'Content-Type' => 'application/json' } )
    rescue => e
      Rails.logger.error("Error updating Elasticsearch learner document for learner #{self.id}: #{e.message}")
    end
  end

  def calculate_last_run
    bundle_logger = self.bundle_logger
    pub_logger = self.periodic_bundle_logger
    bucket_logger = self.bucket_logger
    bundle_time = nil
    pub_time = nil
    bucket_time = nil

    if bundle_logger && bundle_logger.last_non_empty_bundle_content
      bundle_time = bundle_logger.last_non_empty_bundle_content.updated_at
    end

    if pub_logger && pub_logger.periodic_bundle_contents.last
      pub_time = pub_logger.periodic_bundle_contents.last.updated_at
    end

    if bucket_logger && bucket_logger.bucket_contents.last
      bucket_time = bucket_logger.bucket_contents.last.updated_at
    end

    times = [pub_time,bundle_time,bucket_time].compact.sort
    if times.size > 0
      last_run = times.last
    end
    last_run || Time.now
  end

  def update_answers
    report_util = Report::UtilLearner.new(self)

    answersMeta = {
      :num_answerables => report_util.embeddables.size,
      :num_answered => report_util.saveables.count { |s| s.answered? },
      :num_submitted => report_util.saveables.count { |s| s.submitted? },
      :num_correct => report_util.saveables.count { |s|
          (s.respond_to? 'answered_correctly?') ? s.answered_correctly? : false
        },
      :complete_percent => report_util.complete_percent
    }
  end

  def escape_comma(string)
    string&.gsub(',', ' ')
  end
end
