FactoryGirl.define do
  factory :measuring_resistance do |f|
    f.association :offering
    f.association :learner
  end
end
