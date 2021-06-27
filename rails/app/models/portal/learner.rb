class Portal::Learner < ApplicationRecord
  include Rails.application.routes.url_helpers

  self.table_name = :portal_learners

  default_scope { order('portal_learners.student_id ASC') }

  acts_as_replicatable

  belongs_to :student, :class_name => "Portal::Student", :foreign_key => "student_id"
  belongs_to :offering, :class_name => "Portal::Offering", :foreign_key => "offering_id",
    :inverse_of => :learners

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

  [:name, :first_name, :last_name, :email].each { |m| delegate m, :to => :student }

  after_create do |learner|
    # make the report learner now, so two parts of the code aren't trying to create it at the
    # same time later
    learner.report_learner.update_fields
  end

  # 2021-06-21 NP: We update last_run when the run button pressed
  # see offering_controller#show run_resource_html block
  def update_last_run
    self.report_learner.update_attribute('last_run', Time.now)
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
end
