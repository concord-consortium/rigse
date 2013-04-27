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

# capybara needs to make a connection to the rails app that it starts up
# note Around is broken in cucumber becuase it doesn't happen before the Background steps
# and also note that After happens before the capybara deletes the session so disabling
# the network in an After causes an WebMock failure
Before('@javascript') do
  # only allowing localhost connections will let us track down code that
  # connects to external services, but if that is a problem you can
  # change this to:
  # WebMock.allow_net_connect!
  WebMock.disable_net_connect!(:allow_localhost => true)
end
Before('~@javascript') do
  WebMock.disable_net_connect!
end
