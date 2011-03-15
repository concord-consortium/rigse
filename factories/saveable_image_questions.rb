Factory.define :saveable_image_question, :class => Saveable::ImageQuestion do |f|
  f.association :learner, :factory => :full_portal_learner
  f.association :image_question
  f.association :offering, :factory => :portal_offering
end
