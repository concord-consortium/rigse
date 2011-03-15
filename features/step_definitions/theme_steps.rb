Given /^The theme is "([^"]*)"$/ do |name|
  ApplicationController.set_theme(name)
end
