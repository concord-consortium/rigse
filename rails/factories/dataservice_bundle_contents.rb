FactoryBot.define do
  factory :dataservice_bundle_content, :class => Dataservice::BundleContent do |f|
    learner_otml = "<otrunk id='fake_id'><OTText>Hello World</OTText></otrunk>"
    ziped_otml = B64Gzip.pack(learner_otml)
    learner_socks = "<ot.learner.data><sockEntries value=\"#{ziped_otml}\"/></ot.learner.data>"
    f.body {"<sessionBundles>#{learner_socks}</sessionBundles>"}
    f.association :collaboration, :factory => :portal_collaboration
  end
end

FactoryBot.define do
  factory :full_dataservice_bundle_content, :parent => :dataservice_bundle_content do |f|
    f.association :bundle_logger, :factory => :dataservice_bundle_logger
  end
end
