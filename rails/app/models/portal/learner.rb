class Portal::Learner < ApplicationRecord
  include Rails.application.routes.url_helpers

  self.table_name = :portal_learners

  default_scope { order('portal_learners.student_id ASC') }

  acts_as_replicatable

  belongs_to :student, :class_name => "Portal::Student", :foreign_key => "student_id"
  belongs_to :offering, :class_name => "Portal::Offering", :foreign_key => "offering_id",
    :inverse_of => :learners

  has_one :report_learner, :dependent => :destroy, :class_name => "Report::Learner",
    :foreign_key => "learner_id", :inverse_of => :learner

  has_one :report_learner_only_id, -> { select "id, learner_id" }, :class_name => "Report::Learner",
    :foreign_key => "learner_id", :inverse_of => :learner

  default_value_for :secure_key do
    UUIDTools::UUID.random_create.to_s
  end

  # automatically make the report learner if it doesn't exist yet
  def report_learner
    # I'm using the ! here so we can track down errors faster if there is an issue making
    # the report_learner
    super || create_report_learner!
  end

  [:name, :first_name, :last_name, :email].each { |m| delegate m, :to => :student }

  after_create do |learner|
    learner.update_report_model_cache
  end

  # 2021-06-21 NP: We update last_run when the run button pressed
  # see offering_controller#show run_resource_html block
  def update_last_run
    self.report_learner.update_attribute('last_run', Time.now)
    self.update_report_model_cache()
  end

  # 2021-06-21 NP: method deligation because maybe report_learner will go away
  def last_run
    self.report_learner.last_run
  end

  validates_presence_of :student,  :message => "student association not specified"
  validates_presence_of :offering, :message => "offering association not specified"

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

  def elastic_search_learner_model
    {
      learner_id: self.id,
      report_learner_id: self.report_learner_only_id.id,
      student_id: self.student.id,
      user_id:  self.student.user.id,
      remote_endpoint_url: self.remote_endpoint_url,
      created_at: self.created_at,
      offering_id: self.offering.id,
      offering_name: self.offering.name,
      class_id: self.offering.clazz.id,
      class_name: self.offering.clazz.name,
      last_run: self.last_run,
      school_id: self.offering.clazz.school.id,
      school_name: self.offering.clazz.school.name,
      school_name_and_id: "#{self.offering.clazz.school.id}:#{self.offering.clazz.school.name}",
      runnable_id: self.offering.runnable.id,
      runnable_name: self.offering.runnable.name,
      runnable_type: self.offering.runnable.class.to_s.downcase,
      runnable_type_and_id: "#{self.offering.runnable.class.to_s.downcase}_#{self.offering.runnable.id}",
      runnable_type_id_name: "#{self.offering.runnable.class.to_s.downcase}_#{self.offering.runnable.id}:#{self.offering.runnable.name}",
      runnable_url: (self.offering.runnable.respond_to? 'url') ? self.offering.runnable.url : nil,
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

  def escape_comma(string)
    string&.gsub(',', ' ')
  end
end
