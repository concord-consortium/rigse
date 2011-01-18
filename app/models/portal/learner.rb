class Portal::Learner < ActiveRecord::Base
  set_table_name :portal_learners
  
  default_scope :order => 'student_id ASC'
  
  acts_as_replicatable
  
  belongs_to :student, :class_name => "Portal::Student", :foreign_key => "student_id"
  belongs_to :offering, :class_name => "Portal::Offering", :foreign_key => "offering_id"
  
  belongs_to :console_logger, :class_name => "Dataservice::ConsoleLogger", :foreign_key => "console_logger_id", :dependent => :destroy
  belongs_to :bundle_logger, :class_name => "Dataservice::BundleLogger", :foreign_key => "bundle_logger_id", :dependent => :destroy

  has_many :open_responses, :class_name => "Saveable::OpenResponse" do
    def answered
      find(:all).select { |question| question.answered? }
    end
  end
  
  has_many :image_questions, :class_name => "Saveable::ImageQuestion" do
    def answered
      find(:all).select { |question| question.answered? }
    end
  end

  has_many :multiple_choices, :class_name => "Saveable::MultipleChoice" do
    def answered
      find(:all).select { |question| question.answered? }
    end
    def answered_correctly
      find(:all).select { |question| question.answered? }.select{ |item| item.answered_correctly? }
    end
  end

  def sessions
    self.bundle_logger.bundle_contents.length
  end
  
  [:name, :first_name, :last_name, :email, :vendor_interface].each { |m| delegate m, :to => :student }

  before_create do |learner|
    learner.create_console_logger
    learner.create_bundle_logger
  end

  def valid_loggers?
    console_logger && bundle_logger
  end

  def create_new_loggers
    create_console_logger
    create_bundle_logger
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

    def display_name
      "Learner"
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
    runnable.saveable_types.inject(0) do |count, saveable_class|
      saveable_association = saveable_class.to_s.demodulize.tableize
      count + self.send(saveable_association).length
    end
  end
  
  def saveable_answered
    runnable = self.offering.runnable
    runnable.saveable_types.inject(0) do |count, saveable_class|
      saveable_association = saveable_class.to_s.demodulize.tableize
      count + self.send(saveable_association).send(:answered).length
    end
  end
  
  def refresh_saveable_response_objects
    # runnable = self.offering.runnable
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

end