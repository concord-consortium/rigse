Factory.define :dataservice_bundle_logger, :class => Dataservice::BundleLogger do |f|
  f.association :learner, :factory => :full_portal_learner
end

