def add_project_setting_tag(tag_name, setting, value)
  Around(tag_name) do |scenario, block|
    original_value = APP_CONFIG[setting]
    APP_CONFIG[setting] = value
    block.call
    APP_CONFIG[setting] = original_value
  end
end

add_project_setting_tag('@lightweight', :use_jnlps, false)

{ gses: :use_gse,
  adhoc_workgroups: :use_adhoc_workgroups
  }.each{|tag_name, setting|
    add_project_setting_tag("@enable_#{tag_name}", setting, true)
    add_project_setting_tag("@disable_#{tag_name}", setting, false)
  }
