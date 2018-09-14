Factory.sequence(:standard_statement_uri) do |n|
  "http://standard.satement.#{UUIDTools::UUID.timestamp_create.to_s[0..20]}.com"
end

FactoryGirl.define do
  factory :standard_statement, :class => StandardStatement do |f|
    f.uri {FactoryGirl.generate(:standard_statement_uri)}
    f.material_type "external_activity"
  end
end
