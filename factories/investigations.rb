Factory.sequence :investigation_name do |n|
  "test investigation #{UUIDTools::UUID.timestamp_create.to_s}"
end

Factory.define :investigation do |f|
  f.name {Factory.next(:investigation_name)}
  f.description "fake investigation description"
  f.association :user, :factory => :user
end
