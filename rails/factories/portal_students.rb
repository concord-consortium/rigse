FactoryBot.define do
  factory :portal_student, :class => Portal::Student do |f|
  end
end

FactoryBot.define do
  factory :full_portal_student, :parent => :portal_student do |f|
    f.association :user, :factory => :confirmed_user
    f.association :grade_level, :factory => :portal_grade_level
  end
end
