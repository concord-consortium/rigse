require 'digest/md5'  # for the otml md5 this is only for tracking down errors

class Dataservice::BundleContent < ActiveRecord::Base
  require 'otrunk/object_extractor'
  self.table_name = :dataservice_bundle_contents

  belongs_to :bundle_logger, :class_name => "Dataservice::BundleLogger", :foreign_key => "bundle_logger_id"
  has_many :blobs, :class_name => "Dataservice::Blob", :foreign_key => "bundle_content_id"

  has_many :collaborations, :class_name => "Portal::Collaboration", :foreign_key => "bundle_content_id"
  has_many :collaborators, :through => :collaborations, :class_name => "Portal::Student", :source => :student

  has_many :launch_process_events, :class_name => "Dataservice::LaunchProcessEvent", :foreign_key => "bundle_content_id", :order => "id ASC"

  acts_as_list :scope => :bundle_logger_id

  acts_as_replicatable

  include Changeable

  include SailBundleContent

  include BlobExtraction
  
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
    learner = self.bundle_logger.learner
    user = learner.student.user
    name = user.name
    login = user.login
    "#{user.login}: (#{user.name}), #{learner.offering.runnable.name}, session: #{position}"
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
    extract_open_responses(extractor)
    extract_multiple_choices(extractor)
    extract_image_questions(extractor)
    
    # Also create/update a Report::Learner object for reporting
    Report::Learner.for_learner(self.bundle_logger.learner).update_fields
  end
  handle_asynchronously :extract_saveables
  
  def extract_open_responses(extractor = Otrunk::ObjectExtractor.new(self.otml))
    learner = self.bundle_logger.learner
    @offering_id = learner.offering.id
    @learner_id = learner.id
    extractor.find_all('OTText') do |text|
      parent_id = extractor.get_parent_id(text)
      if parent_id && parent_id =~ /open_response_(\d+)/
        process_open_response($1.to_i, extractor.get_text_property(text, 'text'))
      end
    end
  end
  
  def process_open_response(parent_id, answer)
    if Embeddable::OpenResponse.find_by_id(parent_id)
      saveable_open_response = Saveable::OpenResponse.find_or_create_by_learner_id_and_offering_id_and_open_response_id(@learner_id, @offering_id, parent_id)
      if saveable_open_response.response_count == 0 || saveable_open_response.answers.last.answer != answer
        saveable_open_response.answers.create(:bundle_content_id => self.id, :answer => answer)
      end
    else
      logger.error("Missing Embeddable::OpenResponse id: #{parent_id}")
    end
  end
  
  def extract_multiple_choices(extractor = Otrunk::ObjectExtractor.new(self.otml))
    learner = self.bundle_logger.learner
    @offering_id = learner.offering.id
    @learner_id = learner.id
    extractor.find_all('currentChoices') do |choice|
      choices = choice.children
      choices.each do |c|
        next unless c.elem?
        process_multiple_choice($1.to_i) if c.has_attribute?('refid') && c.get_attribute('refid') =~ /(?:embeddable__)?multiple_choice_choice_(\d+)/
        process_multiple_choice($1.to_i) if c.has_attribute?('local_id') && c.get_attribute('local_id') =~ /(?:embeddable__)?multiple_choice_choice_(\d+)/
      end
    end
  end

  def process_multiple_choice(choice_id)
    choice = Embeddable::MultipleChoiceChoice.find_by_id(choice_id, :include => :multiple_choice)
    multiple_choice = choice ? choice.multiple_choice : nil
    answer = choice ? choice.choice : ""
    if multiple_choice && choice
      saveable = Saveable::MultipleChoice.find_or_create_by_learner_id_and_offering_id_and_multiple_choice_id(@learner_id, @offering_id, multiple_choice.id)
      if saveable.answers.empty? || saveable.answers.last.answer != answer
        saveable.answers.create(:bundle_content_id => self.id, :choice_id => choice.id)
      end
    else
      if ! choice
        logger.error("Missing Embeddable::MultipleChoiceChoice id: #{choice_id}")
      elsif ! multiple_choice
        logger.error("Missing Embeddable::MultipleChoice id: #{choice.multiple_choice_id}")
      end
    end
  end
  
  def extract_image_questions(extractor = Otrunk::ObjectExtractor.new(self.otml))
    learner = self.bundle_logger.learner
    @offering_id = learner.offering.id
    @learner_id = learner.id
    extractor.find_all('OTLabbookEntryChooser') do |chooser|
      parent_id = extractor.get_parent_id(chooser)
      if parent_id && parent_id =~ /image_question_(\d+)/
        saveable_image_question = Saveable::ImageQuestion.find_or_create_by_learner_id_and_offering_id_and_image_question_id(@learner_id, @offering_id, $1)
        answer = extractor.get_property_path(chooser, 'embeddedEntries/oTObject').last
        src = answer.nil? ? nil : extractor.get_text_property(answer, 'src')
        if src =~ BLOB_URL_REGEXP
          blob_id = $1
          if saveable_image_question.response_count == 0 || saveable_image_question.answers.last.blob_id != blob_id.to_i
            saveable_image_question.answers.create(:bundle_content_id => self.id, :blob_id => blob_id)
          end
        else
          logger.error("Unknown image question object: #{answer}")
        end
      else                                                                    
        logger.error("Missing Embeddable::ImageQuestion id: #{parent_id}")
      end
    end
  end

  def description
    learner_name = teacher_name = runnable_name = school_name = 'not available'
    begin
      logger = self.bundle_logger
      learner = logger.learner
      learner_name = learner.name
    rescue
    end
    if learner
      begin
        offering = learner.offering
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
    return unless self.bundle_logger
    return unless self.bundle_logger.learner
    return unless self.bundle_logger.learner.offering
    self.collaborators.each do |student|
      slearner = self.bundle_logger.learner.offering.find_or_create_learner(student)
      new_bundle_logger = slearner.bundle_logger
      new_attributes = self.attributes.merge({
        :processed => false,
        :bundle_logger => new_bundle_logger
      })
      bundle_content =Dataservice::BundleContent.create(new_attributes)
      bundle_logger.bundle_contents << bundle_content
      bundle_logger.reload
    end
  end
  handle_asynchronously :copy_to_collaborators
end
