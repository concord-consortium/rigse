class Dataservice::PeriodicBundleContent < ActiveRecord::Base
  set_table_name :dataservice_periodic_bundle_contents

  belongs_to :periodic_bundle_logger, :class_name => "Dataservice::PeriodicBundleLogger"
end
