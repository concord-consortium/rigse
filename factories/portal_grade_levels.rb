Factory.define :portal_grade_level, :class => Portal::GradeLevel  do |f|
  f.name "test"
  f.association :grade, :factory => :portal_grade
end