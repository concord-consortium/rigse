class Dataservice::BundleLogger < ActiveRecord::Base
  set_table_name :dataservice_bundle_loggers
  
  has_one  :learner, :class_name => "Portal::Learner"
  has_many :bundle_contents, :class_name => "Dataservice::BundleContent", :order => :position, :dependent => :destroy
  has_many :latest_bundle_content, :class_name => "Dataservice::BundleContent", :order => :position, :dependent => :destroy, :limit => 1

end
