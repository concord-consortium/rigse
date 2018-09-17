FactoryGirl.define do
  factory :portal_clazz, :class => Portal::Clazz do
    class_word {"classword_#{UUIDTools::UUID.timestamp_create.to_s}"}
    association :course, :factory => :portal_course
    sequence(:name) {|n| "sample class #{n}"}
    uuid {UUIDTools::UUID.timestamp_create.to_s}
  end
end

FactoryGirl.define do
  factory :nces_portal_clazz, :parent => :portal_clazz do
    association :course, :factory => :nces_portal_course
  end
end
