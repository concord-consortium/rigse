class Portal::Learner < ActiveRecord::Base
  set_table_name :portal_learners
  
  acts_as_replicatable
  
  belongs_to :student, :class_name => "Portal::Student", :foreign_key => "student_id"
  belongs_to :offering, :class_name => "Portal::Offering", :foreign_key => "offering_id"
  
  belongs_to :console_logger, :class_name => "Dataservice::ConsoleLogger", :foreign_key => "console_logger_id", :dependent => :destroy
  belongs_to :bundle_logger, :class_name => "Dataservice::BundleLogger", :foreign_key => "bundle_logger_id", :dependent => :destroy
  
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

  class <<self
    def display_name
      "Learner"
    end
  end
end