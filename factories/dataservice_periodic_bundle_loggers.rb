FactoryGirl.define do
  factory :dataservice_periodic_bundle_logger, :class => Dataservice::PeriodicBundleLogger do |f|
    f.association :learner, :factory => :full_portal_learner
  end
end

