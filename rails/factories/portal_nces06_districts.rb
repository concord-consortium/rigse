FactoryBot.define do
  factory :portal_nces06_district, :class => Portal::Nces06District do
    sequence(:NAME) {|n| "factory generated nces district ##{n}"}
  end
end
