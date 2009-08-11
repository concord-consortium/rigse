class Dataservice::BundleContent < ActiveRecord::Base
  set_table_name :dataservice_bundle_contents

  belongs_to :bundle_logger, :class_name => "Dataservice::BundleLogger", :foreign_key => "bundle_logger_id"
  acts_as_list :scope => :bundle_logger_id

  include SailBundleContent
  
  def otml
    @otml || @otml = self.extract_otml
  end
  
  def extract_otml
    ::Zlib::GzipReader.new(StringIO.new(B64::B64.decode(sock_entries[0]))).read
  end
  
end
