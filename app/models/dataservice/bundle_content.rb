class Dataservice::BundleContent < ActiveRecord::Base
  set_table_name :dataservice_bundle_contents

  belongs_to :bundle_logger, :class_name => "Dataservice::BundleLogger", :foreign_key => "bundle_logger_id"

  acts_as_list :scope => :bundle_logger_id

  acts_as_replicatable

  include SailBundleContent
  
  def before_create
    process_bundle
  end

  def before_save
    process_bundle unless processed
  end
  
  def process_bundle
    self.valid_xml = valid_xml?
    self.otml = extract_otml
    self.empty = true unless self.otml
    self.processed = true
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
