FactoryBot.define do
  factory :admin_auto_external_activity_rule, class: Admin::AutoExternalActivityRule do
    name { "Test Rule" }
    slug { "test" }
    description { "This is the test rule" }
    allow_patterns { ".*" }
  end
end
