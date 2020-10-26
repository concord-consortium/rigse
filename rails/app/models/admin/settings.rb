require 'fileutils'

class Admin::Settings < ActiveRecord::Base
  MinPubInterval     = 10   # 10 second update seems close to too fast.
  DefaultPubInterval = 300  # default is five minues
  self.table_name = "admin_settings"

  serialize :enabled_bookmark_types, Array

  after_initialize :init

  belongs_to :user

  belongs_to :default_cohort, :class_name => "Admin::Cohort"

  acts_as_replicatable

  include Changeable
  include AppSettings

  self.extend SearchableModel

  @@searchable_attributes = %w{description}

  default_value_for :pub_interval do
    DefaultPubInterval
  end

  validates :pub_interval, :numericality => { :greater_than_or_equal_to => MinPubInterval }

  def init
    # the description needs to be non null for the searchable model code to work properly
    self.description ||= ''
    self.enabled_bookmark_types ||= []
  end

  # this is a named object but really it doesn't have a name so just return the id
  def name
    id.to_s
  end

  def update_attributes(hashy)
    enabled_bookmark_types = hashy['enabled_bookmark_types']
    if enabled_bookmark_types
      enabled_bookmark_types = enabled_bookmark_types.map { |h| h.split(",") }
      enabled_bookmark_types.flatten!
      enabled_bookmark_types.reject! {|i| i.blank? }
      hashy['enabled_bookmark_types'] = enabled_bookmark_types
    end
    super hashy
  end


  def display_type
    self.default_settings? ? 'Default ' : ''
  end

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    # Admin::Settings.default_settings
    def default_settings
      settings = find_by_active(true)
      if ! settings
        # no active settings; try finding the first settings
        settings = first
        if settings
          logger.warn("No active settings found for using the first settings")
        else
          logger.warn("No settings found")
        end
      end
      settings
    end

    def summary_info
      default_settings ? default_settings.summary_info : "no default settings defined"
    end

    def pub_interval
      default_settings ? default_settings.pub_interval : DefaultPubInterval
    end
    def notify_missing_setting(symbol)
      logger.warn("undefined configuration setting in config/setttings.yml: #{symbol.to_s}")
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

    def teachers_can_author?
      default = default_settings
      return default.teachers_can_author if default
      return false
    end

  end

  def default_settings?
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

There are #{Portal::Teacher.select {|t| t.user == nil}.size} Teachers without Users
There are #{Portal::Student.select {|s| s.user == nil}.size} Students which no longer have Teachers
There are #{Portal::Clazz.select {|i| i.teacher == nil}.size} Classes which no longer have Teachers
There are #{Portal::Learner.select {|i| i.student == nil}.size} Learners which are no longer associated with Students

If these numbers are large you may want to consider cleaning up the database.

# code template for use in script/console

ut = User.find_by_login('teacher'); us = User.find_by_login('student')
t = ut.portal_teacher; s = us.portal_student; c = t.clazzes.first; o = c.offerings.first

HEREDOC
    Rails.logger.info summary
    summary
  end

  def available_bookmark_types
    Portal::Bookmark.available_types.map { |t| t.name }
  end
end
