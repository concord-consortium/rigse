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
  
end
