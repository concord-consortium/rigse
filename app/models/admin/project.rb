require 'fileutils'

class Admin::Project < ActiveRecord::Base
  MinPubInterval     = 10   # 10 second update seems close to too fast.
  DefaultPubInterval = 300  # default is five minues
  set_table_name "admin_projects"
  
  belongs_to :user

  has_many :project_vendor_interfaces, :class_name => "Admin::ProjectVendorInterface", :foreign_key => "admin_project_id"
  has_many :enabled_vendor_interfaces, :through => :project_vendor_interfaces, :class_name => "Probe::VendorInterface", :source => :probe_vendor_interface
  
  serialize :states_and_provinces
 
  acts_as_replicatable
  
  include Changeable
  include AppSettings
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{name description}

  validates_format_of :url, :with => URI::regexp(%w(http https))
  validates_format_of :jnlp_url, :with => URI::regexp(%w(http https))
  validates_length_of :name, :minimum => 1
  validate :states_and_provinces_array_members_must_match_list
  
  default_value_for :enabled_vendor_interfaces do
    Probe::VendorInterface.find(:all)
  end

  default_value_for :pub_interval do
    DefaultPubInterval
  end

  validates_numericality_of :pub_interval, :greater_than_or_equal_to => MinPubInterval

  def states_and_provinces_array_members_must_match_list
    if states_and_provinces && states_and_provinces.is_a?(Array)
      unknown_provinces = states_and_provinces.select { |i| StatesAndProvinces::STATES_AND_PROVINCES[i] ? false : i }
      unless unknown_provinces.empty?
        errors.add(:states_and_provinces, "array members: #{unknown_provinces.join(', ')} must match list of known state and province two-character abreviations")
      end
    else
      errors.add(:states_and_provinces, "must be an array")
    end
  end

  def after_save
    if name == APP_CONFIG[:site_name] && url == APP_CONFIG[:site_url]
      update_app_settings
    end
    if self.enable_default_users
      User.unsuspend_default_users
    else
      User.suspend_default_users
    end
  end

  def update_app_settings
    new_app_settings = load_all_app_settings
    new_app_settings[RAILS_ENV][:site_name] = self.name
    new_app_settings[RAILS_ENV][:site_url] = self.url
    new_app_settings[RAILS_ENV][:enable_default_users] = self.enable_default_users
    new_app_settings[RAILS_ENV][:description] = self.description
    new_app_settings[RAILS_ENV][:states_and_provinces] = self.states_and_provinces
    save_app_settings(new_app_settings)
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
      name, url = default_project_name_url
      proj = find_by_name_and_url(name, url)
      if ! proj
        logger.warn("No default project found for: #{name}, #{url}")
      end
      proj
    end
    
    def default_project_name_url
      [APP_CONFIG[:site_name], APP_CONFIG[:site_url]]
    end

    
    def summary_info
      default_project ? default_project.summary_info : "no default project defined"
    end

    def pub_interval
      default_project ? default_project.pub_interval : DefaultPubInterval
    end

    def create_or_update_default_project_from_settings_yml
      name, url = default_project_name_url
      states_and_provinces = APP_CONFIG[:states_and_provinces]
      enable_default_users = APP_CONFIG[:enable_default_users]

      attributes = {
        :name => name,
        :url => url,
        :user => User.site_admin,
        :enable_default_users => enable_default_users,
        :states_and_provinces => states_and_provinces,
        :snapshot_enabled => snapshot_enabled
      }
      unless project = Admin::Project.find_by_name_and_url(name, url)
        project = Admin::Project.create!(attributes)
      end
      project.user = User.site_admin
      project.enable_default_users = enable_default_users
      project.states_and_provinces = states_and_provinces
      project.snapshot_enabled = snapshot_enabled
      project.save!
      active_grades = APP_CONFIG[:active_grades]
      if ActiveRecord::Base.connection.table_exists?('portal_grades')
        # active_grades.each do |grade_name|
        #   grade = Portal::Grade.find_or_create_by_name(:name => grade_name);
        #   unless grade
        #     grade = Portal::Grade.create(:name => grade_name, :active => true)
        #     puts "created grade #{grade.name}, active: #{grade.active}"
        #   end
        # end
        Portal::Grade.find(:all).each do |grade|
          grade.active = active_grades.include?(grade.name)
          grade.save!
        end
      end
      project
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
    default_name, default_url = Admin::Project.default_project_name_url
    self.name == default_name && self.url == default_url
  end
  
  def summary_info
    puts <<HEREDOC

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
    
  end 
end
