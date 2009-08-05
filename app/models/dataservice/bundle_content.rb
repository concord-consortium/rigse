class Dataservice::BundleContent < ActiveRecord::Base
  set_table_name :dataservice_bundle_contents

  belongs_to :bundle_logger, :class_name => "Dataservice::BundleLogger", :foreign_key => "bundle_logger_id"
  acts_as_list :scope => :bundle_logger_id

  EMPTY_EPORTFOLIO_BUNDLE_PATH = File.join(RAILS_ROOT, 'public', 'bundles', 'empty_bundle.xml')
  EMPTY_EPORTFOLIO_BUNDLE = File.read(EMPTY_EPORTFOLIO_BUNDLE_PATH)
  EMPTY_BUNDLE = " <sessionBundles />\n"
  
  def body
    self[:body] || EMPTY_BUNDLE
  end
  
  def eportfolio
    Dataservice::BundleLogger::OPEN_ELEMENT_EPORTFOLIO + self.body + Dataservice::BundleLogger::CLOSE_ELEMENT_EPORTFOLIO
  end
end
