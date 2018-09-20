FactoryBot.define do
  factory :activity do
    association :user
  end
end

FactoryBot.define do
  factory :activity_template, parent: :activity do
    after(:create) do |act|
      FactoryBot.create_list(:external_activity, 2, template: act, url: "http://activity.external.com/1/2/3")
    end
  end
end
