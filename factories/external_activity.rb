FactoryBot.define do
  factory :external_activity do |f|
    f.association :user
    f.url {'http://external.activitiies.org/123'}
    f.source_type {'LARA'}
  end
end
