class Dataservice::BundleContent < ActiveRecord::Base
  require 'otrunk/object_extractor'
  set_table_name :dataservice_bundle_contents

  belongs_to :bundle_logger, :class_name => "Dataservice::BundleLogger", :foreign_key => "bundle_logger_id"
  has_many :blobs, :class_name => "Dataservice::Blob", :foreign_key => "bundle_content_id"

  acts_as_list :scope => :bundle_logger_id

  acts_as_replicatable

  include Changeable

  include SailBundleContent
  
  before_create :process_bundle
  after_create :process_blobs
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

    def display_name
      "Dataservice::BundleContent"
    end
    
    def b64gzip_unpack(b64gzip_content)
      s = StringIO.new(B64::B64.decode(b64gzip_content))
      z = ::Zlib::GzipReader.new(s)
      return z.read
    end

    def b64gzip_pack(content)
      gzip_string_io = StringIO.new()
      gzip = Zlib::GzipWriter.new(gzip_string_io)
      gzip.write(content)
      gzip.close
      gzip_string_io.rewind
      return B64::B64.encode(gzip_string_io.string)
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
  
  def process_bundle
    return true if self.processed
    self.processed = true
    self.valid_xml = valid_xml?
    # see SailBundleContent mixin for valid_xml? and EMPTY_BUNDLE
    # Calculate self.empty even when the xml is missing or invalid
    self.empty = self.body.nil? || self.body.empty? || self.body == EMPTY_BUNDLE
    if self.valid_xml
      self.otml = extract_otml
      self.empty = true unless self.otml && self.otml.length > 0
    end
  end
    
  def extract_otml
    if body[/ot.learner.data/]
      otml_b64gzip = body.slice(/<sockEntries value="(.*?)"/, 1)
      return self.class.b64gzip_unpack(otml_b64gzip)
      # ::Zlib::GzipReader.new(StringIO.new(B64::B64.decode(otml_b64gzip))).read
    else
      nil
    end
  end
  
  def convert_otml_to_body
    # explicitly flag attributes which will change, especially otml since it has problems auto-detecting it has changed...
    self.otml_will_change!
    self.body_will_change!
    encoded_str = self.class.b64gzip_pack(self.otml)
    unless self.original_body != nil && self.original_body.length > 0
      self.original_body_will_change!
      self.original_body = self.body
    end
    self.body = self.body.sub(/sockEntries value=".*?"/, "sockEntries value=\"#{encoded_str}\"")
  end
  
  @@url_resolver = URLResolver.new
  @@blob_url_regexp = /http.*?\/dataservice\/blobs\/([0-9]+)\.blob\/([0-9a-zA-Z]+)/
  @@blob_content_regexp = /\s*gzb64:([^<]+)/m
  
  def process_blobs
    return false unless self.valid_xml
    ## extract blobs from the otml and convert the changed otml back to bundle format
    blobs_present = extract_blobs
    if blobs_present
      convert_otml_to_body
      self.save!
    end
    return blobs_present
  end
  
  def extract_blobs(host = nil)
    return false if ! self.otml
    
    changed = false
      
    if ! host
      address = URI.parse(APP_CONFIG[:site_url])
      host = address.host
    end

    text = self.otml

		# first find all the previously processed blobs, and re-point their urls
    begin
      text.gsub!(@@blob_url_regexp) {|match|
        changed = true
        match = @@url_resolver.getUrl("dataservice_blob_raw_url", {:id => $1, :token => $2, :host => host, :format => "blob", :only_path => false})
        match
      }
    rescue Exception => e
      $stderr.puts "#{e}: #{$&}"
    end
    
    begin
      # find all the unprocessed blobs, and extract them and create Blob objects for them
      text.gsub!(@@blob_content_regexp) {|match|
        changed = true
        blob = Dataservice::Blob.find_or_create_by_bundle_content_id_and_content(self.id, self.class.b64gzip_unpack($1.gsub!(/\s/, "")))
        match = @@url_resolver.getUrl("dataservice_blob_raw_url", {:id => blob.id, :token => blob.token, :host => host, :format => "blob", :only_path => false})
        match
      }
    rescue Exception => e
      $stderr.puts "#{e}: #{$&}"
    end
    
    self.otml = text if changed
    
    return changed
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
  
  def extract_saveables
    raise "BundleContent ##{self.id}: otml is empty!" unless self.otml && self.otml.size > 17 
    extractor = Otrunk::ObjectExtractor.new(self.otml)
    extract_open_responses(extractor)
    extract_multiple_choices(extractor)
    extract_image_questions(extractor)
  end
  
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
        answer = extractor.get_property_path(chooser, 'embeddedEntries/oTObject').first
        src = answer.nil? ? nil : extractor.get_text_property(answer, 'src')
        if src =~ @@blob_url_regexp
          blob_id = $1
          if saveable_image_question.response_count == 0 || saveable_image_question.answers.last.blob_id != blob_id
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
end
