Given /^the following web models exist:$/ do |table|
  table.hashes.each do |hash|
    Factory :web_model, hash
  end
end

When /^I follow "([^"]*)" for the web model "([^"]*)"$/ do |link, wm_name|
  web_model = WebModel.find_by_name wm_name
  steps %Q{
    When I follow "#{link}" within "#web_model_#{web_model.id}"
  }
end
