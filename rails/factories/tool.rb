FactoryBot.define do
  factory :tool do |f|
  end

  factory :lara_tool, class: Tool do |f|
    f.source_type {"LARA"}
    f.name {"LARA"}
  end

  factory :ap_tool, class: Tool do |f|
    f.source_type {"Activity Player"}
    f.name {"Activity Player"}
  end
end
