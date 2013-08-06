Factory.define :dataservice_periodic_bundle_content, :class => Dataservice::PeriodicBundleContent do |f|
  f.body "<otrunk id='fake_id'><OTText>Hello World</OTText></otrunk>"
end

Factory.define :full_dataservice_periodic_bundle_content, :parent => :dataservice_periodic_bundle_content do |f|
  f.association :periodic_bundle_logger, :factory => :dataservice_periodic_bundle_logger
end

