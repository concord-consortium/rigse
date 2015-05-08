Factory.sequence :interactive_name do |n|
  "test investigation #{UUIDTools::UUID.timestamp_create.to_s}"
end

Factory.define :interactive do |f|
  f.name {Factory.next(:interactive_name)}
end