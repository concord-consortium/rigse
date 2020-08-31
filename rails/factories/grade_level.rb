FactoryBot.define do
  factory :grade_level, :class => Portal::GradeLevel do |f|
    association :grade
  end
end

