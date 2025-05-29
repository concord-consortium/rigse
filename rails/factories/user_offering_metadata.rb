FactoryBot.define do
  factory :user_offering_metadata do
    user { nil }
    offering { nil }
    active { false }
    locked { false }
  end
end
