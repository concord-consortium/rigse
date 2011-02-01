Factory.define :portal_student_clazz, :class => Portal::StudentClazz do |f|
  f.association :student, :factory => :portal_student
  f.association :clazz,   :factory => :portal_clazz
end

