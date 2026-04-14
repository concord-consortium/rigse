FactoryBot.define do
  factory :tool do |f|
    f.source_type {"Tool Type"}
    f.name {"Tool Name"}
    f.tool_id {"http://tool.host/"}
  end

  factory :lara_tool, class: Tool do |f|
    f.source_type {"LARA"}
    f.name {"LARA"}
    f.tool_id {"http://lara.test.host/"}
  end

  factory :ap_tool, class: Tool do |f|
    f.source_type {"Activity Player"}
    f.name {"Activity Player"}
    f.tool_id {"http://ap.test.host/"}
  end

  factory :oauth2_tool, class: Tool do |f|
    f.source_type {"OAuth2 Tool Type"}
    f.name {"OAuth2 Tool"}
    f.tool_id {"http://oauth2-tool.test.host/"}
    f.launch_method {"oauth2"}
  end
end
