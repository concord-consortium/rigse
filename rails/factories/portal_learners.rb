FactoryBot.define do
  factory :portal_learner, :class => Portal::Learner do
  end
end

FactoryBot.define do
  factory :full_portal_learner, :parent => :portal_learner do
    uuid {"test"}
    association :student, :factory => :full_portal_student
    association :offering, :factory => :portal_offering

    after(:create) {|learner| learner.offering.clazz.students << learner.student}
  end
end
