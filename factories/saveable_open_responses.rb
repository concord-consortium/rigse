Factory.define :saveable_open_response, :class => Saveable::OpenResponse do |f|
  f.association :learner, :factory => :full_portal_learner
  f.association :open_response
  f.association :offering, :factory => :portal_offering
end
