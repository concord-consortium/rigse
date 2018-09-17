FactoryGirl.define do
  factory :investigation do
    name {"test investigation #{UUIDTools::UUID.timestamp_create.to_s}"}
    description "fake investigation description"
    user {FactoryGirl.generate(:author_user)}
  end
end

FactoryGirl.define do
  factory :investigation_template, parent: :investigation do
    after(:create) do |inv|
      FactoryGirl.create_list(:external_activity, 2, template: inv, url: "http://activity.external.com/1/2/3")
    end
  end
end
