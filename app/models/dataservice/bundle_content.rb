require 'digest/md5'  # for the otml md5 this is only for tracking down errors

class Dataservice::BundleContent < ActiveRecord::Base
  require 'otrunk/object_extractor'
  self.table_name = :dataservice_bundle_contents

  belongs_to :bundle_logger, :class_name => "Dataservice::BundleLogger", :foreign_key => "bundle_logger_id"
  delegate :learner, :to => :bundle_logger, :allow_nil => true

  has_many :blobs, :class_name => "Dataservice::Blob", :foreign_key => "bundle_content_id"

  belongs_to :collaboration, :class_name => "Portal::Collaboration"
  has_many :collaborators, :through => :collaboration, :class_name => "Portal::Student", :source => :students

  has_many :launch_process_events, :dependent => :destroy, :class_name => "Dataservice::LaunchProcessEvent", :foreign_key => "bundle_content_id", :order => "id ASC"

  acts_as_list :scope => :bundle_logger_id

  acts_as_replicatable

  include Changeable

  # pagination default
  cattr_reader :per_page
  @@per_page = 5

  self.extend SearchableModel

  @@searchable_attributes = %w{body otml uuid}

  class <<self


    def searchable_attributes
      @@searchable_attributes
    end
  end

  def user
    nil
  end

  def name
    user = self.learner.student.user
    name = user.name
    login = user.login
    "#{user.login}: (#{user.name}), #{self.learner.offering.runnable.name}, session: #{position}"
  end

  def owner
    self.learner.student
  end

  def collaboration_owner_bundle?
    return self.owner == self.collaboration.owner
  end

  def session_uuid
    return nil if self.body.nil?
    return self.body[/sessionUUID="([^"]*)"/, 1]
  end

  def previous_session_uuid
    return nil if self.body.nil?
    return self.body[/<launchProperties key="previous.bundle.session.id" value="([^"]*)"/, 1]
  end

  def session_start
    return nil if self.body.nil?
    begin
      DateTime.parse(self.body[/start="([^"]*)"/, 1])
    rescue
      nil
    end
  end

  def session_stop
    return nil if self.body.nil?
    begin
      DateTime.parse(self.body[/stop="([^"]*)"/, 1])
    rescue
      nil
    end
  end

  # localIP="10.81.18.190"
  def local_ip
    return nil if self.body.nil?
    return self.body[/localIP="([^"]*)"/, 1]
  end

  def record_bundle_processing
    self.updated_at = Time.now
    self.processed = true
  end

  def description
    learner_name = teacher_name = runnable_name = school_name = 'not available'
    begin
      learner_name = self.learner.name
    rescue
    end
    if self.learner
      begin
        offering = self.learner.offering
        begin
          runnable = offering.runnable
          runnable_name = runnable.name
        rescue
        end
        begin
          teacher = offering.clazz.teacher
          teacher_name = teacher.name
          begin
            school = teacher.school
            school_name = school.name
          rescue
          end
        rescue
        end
      rescue
      end
    end
    <<-HEREDOC
    This session bundle comes from learner data created on #{self.created_at} by '#{learner_name}' in '#{teacher_name}'s
    class using: '#{runnable_name}' in the '#{school_name}' school.
    HEREDOC
  end

  def copy_to_collaborators
    return unless self.collaborators.size > 0
    return unless self.learner && self.learner.offering
    # Make sure that we copy data to other learners only once, when we process bundle
    # that belongs to collaboration owner. Otherwise we would have started endless copy cycle.
    return unless self.collaboration_owner_bundle?
    self.collaborators.each do |student|
      # Do not replicate bundle that already exists (+ the same issue as above - endless copy cycle).
      next if student == self.owner
      slearner = self.learner.offering.find_or_create_learner(student)
      new_bundle_logger = slearner.bundle_logger
      new_attributes = self.attributes.merge({
        :processed => false,
        :bundle_logger => new_bundle_logger
      })
      bundle_content =Dataservice::BundleContent.create(new_attributes)
      new_bundle_logger.bundle_contents << bundle_content
      new_bundle_logger.reload
    end
  end
end
