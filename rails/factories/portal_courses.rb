FactoryBot.define do
  factory :portal_course, :class => Portal::Course do |f|
    f.name {"first course"}
    f.course_number {UUIDTools::UUID.timestamp_create.to_s[0..5]}
    f.uuid {UUIDTools::UUID.timestamp_create.to_s}
    f.association :school, :factory => :portal_school
  end
end

FactoryBot.define do
  factory :nces_portal_course, :parent => :portal_course do |f|
    f.association :school, :factory => :nces_portal_school
  end
end
