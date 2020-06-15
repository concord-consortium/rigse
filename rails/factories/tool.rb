FactoryBot.define do
  factory :tool do |f|
  end

  factory :lara_tool, class: Tool do |f|
    f.source_type {"LARA"}
    f.name {"LARA"}
  end
end
