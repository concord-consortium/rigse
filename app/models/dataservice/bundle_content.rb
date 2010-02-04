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
  
  OR_MATCHER = /open_response_(\d+).*?<OTText text="(.*?)" \/>/m
  
  def extract_open_responses
    learner = self.bundle_logger.learner
    md = OR_MATCHER.match(self.otml)
    while md
      embeddable_open_response_id = md[1]
      answer = md[2]
      if Embeddable::OpenResponse.find_by_id(embeddable_open_response_id)
        saveable_open_response = Saveable::OpenResponse.find_or_create_by_learner_id_and_open_response_id(learner.id, embeddable_open_response_id)
        if saveable_open_response.answers.empty? || saveable_open_response.answers.last.answer != answer
          Saveable::OpenResponseAnswer.create(:bundle_content_id => self.id, :open_response_id => saveable_open_response.id, :answer => answer)
        end
      else
        logger.error("Missing Embeddable::OpenResponse id: #{embeddable_open_response_id}")
      end
      content = md.post_match
      md = OR_MATCHER.match(content)
    end
  end
  
  MC_MATCHER = /currentChoices.*?refid=".*?(?:embeddable__)?multiple_choice_choice_(\d+)"/m
  def extract_multiple_choices
    learner = self.bundle_logger.learner
    content = self.otml
    while md = MC_MATCHER.match(content)
      choice = Embeddable::MultipleChoiceChoice.find_by_id(md[1], :include => :multiple_choice)
      multiple_choice = choice ? choice.multiple_choice : nil
      answer = choice.choice
      if multiple_choice && choice
        saveable = Saveable::MultipleChoice.find_or_create_by_learner_id_and_multiple_choice_id(learner.id, multiple_choice.id)
        if saveable.answers.empty? || saveable.answers.last.answer != answer
          Saveable::MultipleChoiceAnswer.create(:bundle_content_id => self.id, :multiple_choice_id => saveable.id, :choice_id => choice.id)
        end
      else
        if ! choice
          logger.error("Missing Embeddable::MultipleChoiceChoice id: #{md[1]}")
        elsif ! multiple_choice
          logger.error("Missing Embeddable::MultipleChoice id: #{choice.multiple_choice_id}")
        end
      end
      content = md.post_match
    end
  end
  
end
