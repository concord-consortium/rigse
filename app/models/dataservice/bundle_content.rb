class Dataservice::BundleContent < ActiveRecord::Base
  set_table_name :dataservice_bundle_contents

  belongs_to :bundle_logger, :class_name => "Dataservice::BundleLogger", :foreign_key => "bundle_logger_id"

  acts_as_list :scope => :bundle_logger_id

  def body
    unless bundle = self[:body]
      debugger
      bundle = File.read(File.join(RAILS_ROOT, 'public', 'bundles', 'empty_bundle.xml'))
    end
    bundle
  end
end
