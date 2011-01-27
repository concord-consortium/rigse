Factory.define :portal_student, :class => Portal::Student do |f|
end

Factory.define :full_portal_student, :parent => :portal_student do |f|
  f.association :user
  f.association :grade_level, :factory => :full_portal_grade_level
end

