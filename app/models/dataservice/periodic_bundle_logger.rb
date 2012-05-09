class Dataservice::PeriodicBundleLogger < ActiveRecord::Base
  set_table_name :dataservice_periodic_bundle_loggers

  serialize :imports

  belongs_to :learner, :class_name => "Portal::Learner"
  has_many :periodic_bundle_contents, :class_name => "Dataservice::PeriodicBundleContent", :order => :created_at, :dependent => :destroy
  has_many :periodic_bundle_parts, :class_name => "Dataservice::PeriodicBundlePart", :order => :created_at, :dependent => :destroy

  ## FIXME How do we handle launch process events?

end
