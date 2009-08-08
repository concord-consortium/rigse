class Portal::Learner < ActiveRecord::Base
  set_table_name :portal_learners
  
  acts_as_replicatable
  
  belongs_to :student, :class_name => "Portal::Student", :foreign_key => "student_id"
  belongs_to :offering, :class_name => "Portal::Offering", :foreign_key => "offering_id"
  
  belongs_to :console_logger, :class_name => "Dataservice::ConsoleLogger", :foreign_key => "console_logger_id"
  belongs_to :bundle_logger, :class_name => "Dataservice::BundleLogger", :foreign_key => "bundle_logger_id"
  
  [:name, :first_name, :last_name, :email, :vendor_interface].each { |m| delegate m, :to => :student }

  after_create do |learner|
    learner.console_logger = Dataservice::ConsoleLogger.create!
    learner.bundle_logger = Dataservice::BundleLogger.create!
  end

  before_save do |learner|
    learner.console_logger = Dataservice::ConsoleLogger.create! unless learner.console_logger
    learner.bundle_logger = Dataservice::BundleLogger.create! unless learner.bundle_logger
  end

end