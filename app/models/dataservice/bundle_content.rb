class Dataservice::BundleContent < ActiveRecord::Base
  set_table_name :dataservice_bundle_contents

  belongs_to :bundle_logger, :class_name => "Dataservice::BundleLogger", :foreign_key => "bundle_logger_id"

  acts_as_list :scope => :bundle_logger_id

  acts_as_replicatable

  include Changeable

  include SailBundleContent
  
  def before_create
    process_bundle
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
      s = StringIO.new(B64::B64.decode(otml_b64gzip))
      z = ::Zlib::GzipReader.new(s)
      z.read
      # ::Zlib::GzipReader.new(StringIO.new(B64::B64.decode(otml_b64gzip))).read
    else
      nil
    end
  end
  
  def convert_otml_to_body
    gzip_string_io = StringIO.new()
    gzip = Zlib::GzipWriter.new(gzip_string_io)
    gzip.write(self.otml)
    gzip.close
    gzip_string_io.rewind
    encoded_str = B64::B64.encode(gzip_string_io.string)
    self.body.sub(/sockEntries value=".*?"/, "sockEntries value=\"#{encoded_str}\"")
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
