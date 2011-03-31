Given /^the investigation "([^"]*)" is tagged with "([^"]*)"$/ do |inv_name, tag|
  inv = Investigation.find_by_name inv_name
  inv.tag_list = tag
  inv.save
end

Given /^the resource page "([^"]*)" is tagged with "([^"]*)"$/ do |rp_name, tag|
  rp = ResourcePage.find_by_name rp_name
  rp.tag_list = tag
  rp.save
end

Given /^the external activity "([^"]*)" is tagged with "([^"]*)"$/ do |ea_name, tag|
  ea = ExternalActivity.find_by_name ea_name
  ea.tag_list = tag
  ea.save
end

Given /^the page "([^"]*)" is tagged with "([^"]*)"$/ do |page_name, tag|
  page = Page.find_by_name page_name
  page.tag_list = tag
  page.save
end

Given /^the activity "([^"]*)" is tagged with "([^"]*)"$/ do |act_name, tag|
  act = Activity.find_by_name act_name
  act.tag_list = tag
  act.save
end

