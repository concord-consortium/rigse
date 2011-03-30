Factory.define :page do |f|
  f.name "first page"
  f.description "a description of the first page"
  f.position 1
  f.teacher_only false
  f.association :user
end
