FactoryBot.define do
  factory :portal_offering, :class => Portal::Offering do |f|
    f.association :runnable, :factory => :external_activity
    f.association :clazz, :factory => :portal_clazz
  end
end
