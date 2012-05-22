require 'digest/md5'  # for the otml md5 this is only for tracking down errors

class Dataservice::BundleContent < ActiveRecord::Base
  require 'otrunk/object_extractor'
  self.table_name = :dataservice_bundle_contents

  belongs_to :bundle_logger, :class_name => "Dataservice::BundleLogger", :foreign_key => "bundle_logger_id"
  delegate :learner, :to => :bundle_logger, :allow_nil => true

  has_many :blobs, :class_name => "Dataservice::Blob", :foreign_key => "bundle_content_id"

  has_many :collaborations, :class_name => "Portal::Collaboration", :foreign_key => "bundle_content_id"
  has_many :collaborators, :through => :collaborations, :class_name => "Portal::Student", :source => :student

  has_many :launch_process_events, :class_name => "Dataservice::LaunchProcessEvent", :foreign_key => "bundle_content_id", :order => "id ASC"

  acts_as_list :scope => :bundle_logger_id

  acts_as_replicatable

  include Changeable

  include SailBundleContent

  include BlobExtraction
  include SaveableExtraction
  
  before_save :process_bundle
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
  
  def otml
    self[:otml] || ''
  end
  
  def name
    user = self.learner.student.user
    name = user.name
    login = user.login
    "#{user.login}: (#{user.name}), #{self.learner.offering.runnable.name}, session: #{position}"
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

  def otml_hash
    otml_text = self.otml
    return nil if otml_text.nil? || otml_text.empty?
    # this is only for debugging issues so it is fine to change the hash function
    Digest::MD5.hexdigest(otml_text)
  end

  def record_bundle_processing
    self.updated_at = Time.now
    self.processed = true
  end

  def process_bundle
    # this method shouldn't be called multiple times,
    # but even if it is, no harm should come
    # return true if self.processed
    self.record_bundle_processing
    self.valid_xml = valid_xml?
    # see SailBundleContent mixin for valid_xml? and EMPTY_BUNDLE
    # Calculate self.empty even when the xml is missing or invalid
    self.empty = self.body.nil? || self.body.empty? || self.body == EMPTY_BUNDLE
    if self.valid_xml
      self.otml = extract_otml
      self.empty = true unless self.otml && self.otml.length > 0
    end
    self.process_blobs
    true # don't stop the callback chain.
  end
  
  def extract_otml
    if body[/ot.learner.data/]
      otml_b64gzip = body.slice(/<sockEntries value="(.*?)"/, 1)
      return B64Gzip.unpack(otml_b64gzip)
      # ::Zlib::GzipReader.new(StringIO.new(B64::B64.decode(otml_b64gzip))).read
    else
      nil
    end
  end
  
  def convert_otml_to_body
    # explicitly flag attributes which will change, especially otml since it has problems auto-detecting it has changed...
    self.otml_will_change!
    self.body_will_change!
    encoded_str = B64Gzip.pack(self.otml)
    unless self.original_body != nil && self.original_body.length > 0
      self.original_body_will_change!
      self.original_body = self.body
    end
    self.body = self.body.sub(/sockEntries value=".*?"/, "sockEntries value=\"#{encoded_str}\"")
  end
  
  def process_blobs
    # return true unless self.valid_xml
    # we want to give other callbacks a chance to run
    return false unless self.valid_xml
    ## extract blobs from the otml and convert the changed otml back to bundle format
    blobs_present = extract_blobs
    if blobs_present
      convert_otml_to_body
      #self.save!
    end
    return blobs_present
    # above would stop other callbacks from happening
    # return true 
  end

  def bundle_content_return_address
    return_address = nil
    if self.bundle_content =~ /sdsReturnAddresses>(.*?)<\/sdsReturnAddresses/m
      begin
        return URI.parse($1)
      rescue
      end
    end
    return nil
  end
  
  def otml_empty?
    !self.otml || self.otml.size <= 17
  end
  
  def extract_saveables
    raise "BundleContent ##{self.id}: otml is empty!" if otml_empty?
    extractor = Otrunk::ObjectExtractor.new(self.otml)
    extract_everything(extractor)

    # Also create/update a Report::Learner object for reporting
    Report::Learner.for_learner(learner).update_fields if learner
  end
  handle_asynchronously :extract_saveables
  
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
    self.collaborators.each do |student|
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
  handle_asynchronously :copy_to_collaborators
end
