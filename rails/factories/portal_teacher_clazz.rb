FactoryBot.define do
  factory :portal_teacher_clazz, :class => Portal::TeacherClazz do
    association :teacher, :factory => :portal_teacher
    association :clazz, :factory => :portal_clazz
  end
end
