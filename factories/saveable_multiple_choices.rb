Factory.define :saveable_multiple_choice, :class => Saveable::MultipleChoice do |f|
  f.association :learner, :factory => :full_portal_learner
  f.association :multiple_choice
  f.association :offering, :factory => :portal_offering
end