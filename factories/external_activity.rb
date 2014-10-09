Factory.define :external_activity do |f|
  f.association :user
  f.url  'http://external.activitiies.org/123'
end
