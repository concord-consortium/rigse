FactoryBot.define do
  factory :standard_statement, :class => StandardStatement do |f|
    f.uri {"http://standard.satement.#{UUIDTools::UUID.timestamp_create.to_s[0..20]}.com"}
    f.material_type "external_activity"
  end
end
