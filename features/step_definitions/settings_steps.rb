
Given /^the configuration setting for "([^"]*)" is "([^"]*)"$/ do |key, value|
  key = key.to_sym
  begin
    value = eval(value)  # eg : "false" => false
  rescue
    value = value        # eg : "green" => "green"
  end
  # App config is a constant, but its key value pairs are mutable
  APP_CONFIG[key] = value
end

