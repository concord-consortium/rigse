Factory.sequence :investigation_name do |n|
  "test investigation #{UUIDTools::UUID.timestamp_create.to_s}"
end

Factory.define :investigation do |f|
  f.name {Factory.next(:investigation_name)}
  f.description "fake investigation description"
  f.user { Factory.next(:author_user) }
end

Factory.define :investigation_template, parent: :investigation do |f|
  f.after_create do |inv|
    FactoryGirl.create_list(:external_activity, 2, template: inv, url: "http://activity.external.com/1/2/3")
  end
end
