FactoryGirl.define do
  factory :activity do
    association :user
  end
end

FactoryGirl.define do
  factory :activity_template, parent: :activity do
    after(:create) do |act|
      FactoryGirl.create_list(:external_activity, 2, template: act, url: "http://activity.external.com/1/2/3")
    end
  end
end
