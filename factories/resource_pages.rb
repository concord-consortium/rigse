Factory.sequence :resource_page_name do |n|
  "test resource page #{UUIDTools::UUID.timestamp_create.to_s}"
end

Factory.define :resource_page do |f|
  f.name {Factory.next(:resource_page_name)}
  f.description "fake resource page description"
  f.association :user, :factory => :user
  f.publication_status "published"
end
