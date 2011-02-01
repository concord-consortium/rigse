Factory.sequence :attached_file_name do |n|
  "test attached file #{UUIDTools::UUID.timestamp_create.to_s}"
end

Factory.define :attached_file do |f|
  f.name {Factory.next(:attached_file_name)}
  f.association :user, :factory => :user
  f.association :attachable, :factory => :resource_page
end
