class Dataservice::BundleContent < ActiveRecord::Base
  set_table_name :dataservice_bundle_contents

  belongs_to :bundle_logger, :class_name => "Dataservice::BundleLogger", :foreign_key => "bundle_logger_id"
  has_many :blobs, :class_name => "Dataservice::Blob", :foreign_key => "bundle_content_id"

  acts_as_list :scope => :bundle_logger_id

  acts_as_replicatable

  include Changeable

  include SailBundleContent
  
  def before_create
    process_bundle
  end
  
  def after_create
    process_blobs
  end

  def before_save
    process_bundle unless processed
  end
  
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
    self.processed = true
    self.valid_xml = valid_xml?
    if valid_xml
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
    extract_open_responses
    extract_multiple_choices
  end
  
  OR_MATCHER = /open_response_(\d+).*?<OTText.*?(?:(?:text="(.*?)")|(?:<text>(.*?)<\/text>))/m
  def extract_open_responses
    learner = self.bundle_logger.learner
    @offering_id = learner.offering.id
    @learner_id = learner.id
    if match_data = OR_MATCHER.match(self.otml)
      while OR_MATCHER.match(process_open_response(match_data))
        match_data = $~
      end
    end
  end
  
  def process_open_response(match_data)
    if Embeddable::OpenResponse.find_by_id(match_data[1])
      saveable_open_response = Saveable::OpenResponse.find_or_create_by_learner_id_and_offering_id_and_open_response_id(@learner_id, @offering_id, match_data[1])
      answer = match_data[2] ? match_data[2] : match_data[3]
      if saveable_open_response.response_count == 0 || saveable_open_response.answers.last.answer != answer
        saveable_open_response.answers.create(:bundle_content_id => self.id, :answer => answer)
      end
    else
      logger.error("Missing Embeddable::OpenResponse id: #{match_data[1]}")
    end
    match_data.post_match
  end
  
  MC_MATCHER = /currentChoices.*?refid=".*?(?:embeddable__)?multiple_choice_choice_(\d+)"/m
  def extract_multiple_choices
    learner = self.bundle_logger.learner
    @offering_id = learner.offering.id
    @learner_id = learner.id
    if match_data = MC_MATCHER.match(self.otml)
      while MC_MATCHER.match(process_multiple_choice(match_data))
        match_data = $~
      end
    end
  end

  def process_multiple_choice(match_data)
    choice = Embeddable::MultipleChoiceChoice.find_by_id(match_data[1], :include => :multiple_choice)
    multiple_choice = choice ? choice.multiple_choice : nil
    answer = choice ? choice.choice : ""
    if multiple_choice && choice
      saveable = Saveable::MultipleChoice.find_or_create_by_learner_id_and_offering_id_and_multiple_choice_id(@learner_id, @offering_id, multiple_choice.id)
      if saveable.answers.empty? || saveable.answers.last.answer != answer
        saveable.answers.create(:bundle_content_id => self.id, :choice_id => choice.id)
      end
    else
      if ! choice
        logger.error("Missing Embeddable::MultipleChoiceChoice id: #{match_data[1]}")
      elsif ! multiple_choice
        logger.error("Missing Embeddable::MultipleChoice id: #{choice.multiple_choice_id}")
      end
    end
    match_data.post_match
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
