Factory.sequence :class_word do |n|
  "classword_#{UUIDTools::UUID.timestamp_create.to_s}"
end

Factory.sequence :class_name do |n|
  "sample class #{n}"
end

Factory.define :portal_clazz, :class => Portal::Clazz do |f|
  f.class_word {Factory.next(:class_word)}
  f.association :course, :factory => :portal_course
  f.name {Factory.next(:class_name)}
  f.uuid { UUIDTools::UUID.timestamp_create.to_s }
end

Factory.define :nces_portal_clazz, :parent => :portal_clazz do |f|
  f.association :course, :factory => :nces_portal_course
end
