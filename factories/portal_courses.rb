Factory.sequence :course_number do |n|
  UUIDTools::UUID.timestamp_create.to_s[0..5]
end


Factory.define :portal_course, :class => Portal::Course do |f|
  f.name  "first course"
  f.course_number {Factory.next(:course_number)}
  f.uuid  UUIDTools::UUID.timestamp_create.to_s
  f.association :school, :factory => :portal_school
end

Factory.define :nces_portal_course, :parent => :portal_course do |f|
  f.association :school, :factory => :nces_portal_school
end
