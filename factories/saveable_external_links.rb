Factory.define :saveable_external_link, :class => Saveable::ExternalLink do |f|
  f.association :learner, :factory => :full_portal_learner
  f.association :embeddable, :factory => :embeddable_iframe
  f.association :offering, :factory => :portal_offering
end
