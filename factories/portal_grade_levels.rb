Factory.define :portal_grade_level, :class => Portal::GradeLevel do |f|
  f.name "test"
  f.association :grade, :factory => :portal_grade
end

Factory.define :full_portal_grade_level, :parent => :portal_grade_level  do |f|
  f.name "test"
  f.association :grade, :factory => :portal_grade
end
