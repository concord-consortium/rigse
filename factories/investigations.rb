FactoryBot.define do
  factory :investigation do
    name {"test investigation #{UUIDTools::UUID.timestamp_create.to_s}"}
    description {"fake investigation description"}
    user {FactoryBot.generate(:author_user)}
  end
end

FactoryBot.define do
  factory :investigation_template, parent: :investigation do
    after(:create) do |inv|
      FactoryBot.create_list(:external_activity, 2, template: inv, url: "http://activity.external.com/1/2/3")
    end
  end
end
