FactoryBot.define do
  factory :interactive do
    name {"test investigation #{UUIDTools::UUID.timestamp_create.to_s}"}
  end
end
