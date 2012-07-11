require 'fileutils'

class Admin::Project < ActiveRecord::Base
  self.table_name = "admin_projects"
  
  after_initialize :init

  belongs_to :user

  has_many :project_vendor_interfaces, :class_name => "Admin::ProjectVendorInterface", :foreign_key => "admin_project_id"
  has_many :enabled_vendor_interfaces, :through => :project_vendor_interfaces, :class_name => "Probe::VendorInterface", :source => :probe_vendor_interface
  
  acts_as_replicatable
  
  include Changeable
  include AppSettings
  
  self.extend SearchableModel

  @@searchable_attributes = %w{description}

  default_value_for :enabled_vendor_interfaces do
    Probe::VendorInterface.all
  end
  
  def init
    # the description needs to be non null for the searchable model code to work properly
    self.description ||= ''
  end

  # this is a named object but really it doesn't have a name so just return the id
  def name
    id.to_s
  end

  def using_custom_css?
    return (! (self.custom_css.nil? || self.custom_css.strip.empty?))
  end

  def display_type
    self.default_project? ? 'Default ' : ''
  end
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    # Admin::Project.default_project
    def default_project
      proj = find_by_active(true)
      if ! proj
        # no active projects try finding the first project
        proj = first
        if proj
          logger.warn("No active project found for using the first project")
        else
          logger.warn("No projects found")
        end
      end
      proj
    end
    
    def summary_info
      default_project ? default_project.summary_info : "no default project defined"
    end

    def notify_missing_setting(symbol)
      logger.warn("undefined configuartion setting in config/setttings.yml: #{symbol.to_s}")
    end
    
    def settings_for(symbol)
      value = APP_CONFIG[symbol]
      if value.nil? 
        notify_missing_setting(symbol)
      end
      return APP_CONFIG[symbol]
    end

    def require_activity_descriptions
      return settings_for(:require_activity_descriptions)
    end

    def unique_activity_names
      return settings_for(:unique_activity_names)
    end
  end
  
  def default_project?
    active
  end
  
  def summary_info
    summary = <<HEREDOC

Portal::District: #{Portal::District.count}
Portal::School:   #{Portal::School.count}
Portal::Course:   #{Portal::Course.count}
Portal::Clazz:    #{Portal::Clazz.count}
Portal::Teacher:  #{Portal::Teacher.count}

Portal::Student:  #{Portal::Student.count}
Portal::Offering: #{Portal::Offering.count}
Portal::Learner:  #{Portal::Learner.count}

Dataservice::BundleLogger:  #{Dataservice::BundleLogger.count}
Dataservice::BundleContent: #{Dataservice::BundleContent.count}
Dataservice::ConsoleLogger:  #{Dataservice::ConsoleLogger.count}
Dataservice::ConsoleContent: #{Dataservice::ConsoleContent.count}

There are #{Portal::Teacher.find(:all).select {|t| t.user == nil}.size} Teachers without Users
There are #{Portal::Student.find(:all).select {|s| s.user == nil}.size} Students which no longer have Teachers
There are #{Portal::Clazz.find(:all).select {|i| i.teacher == nil}.size} Classes which no longer have Teachers
There are #{Portal::Learner.find(:all).select {|i| i.student == nil}.size} Learners which are no longer associated with Students

If these numbers are large you may want to consider cleaning up the database.

# code template for use in script/console

ut = User.find_by_login('teacher'); us = User.find_by_login('student')
t = ut.portal_teacher; s = us.portal_student; c = t.clazzes.first; o = c.offerings.first

HEREDOC
    puts summary
    summary
  end 
end
