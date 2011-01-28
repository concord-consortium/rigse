Factory.define :portal_learner, :class => Portal::Learner do |f|
end

Factory.define :full_portal_learner, :parent => :portal_learner do |f|
  f.uuid "test"
  f.association :student, :factory => :full_portal_student
  f.association :offering, :factory => :portal_offering
end

