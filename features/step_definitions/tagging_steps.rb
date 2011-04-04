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

Then /^the external activity "([^"]*)" should be tagged with "([^"]*)"$/ do |ea_name, tag|
  ea = ExternalActivity.find_by_name ea_name
  ea.tag_list.should include tag
end

Then /^the investigation "([^"]*)" should be tagged with "([^"]*)"$/ do |inv_name, tag|
  inv = Investigation.find_by_name inv_name
  inv.tag_list.should include tag
end

Then /^the page "([^"]*)" should be tagged with "([^"]*)"$/ do |page_name, tag|
  page = Page.find_by_name page_name
  page.tag_list.should include tag
end

Then /^the activity "([^"]*)" should be tagged with "([^"]*)"$/ do |act_name, tag|
  act = Activity.find_by_name act_name
  act.tag_list.should include tag
end

Given /^the following investigations are tagged with "([^"]*)":$/ do |tag, table|
  table.hashes.each do |inv_hash|
    inv = Investigation.find_by_name inv_hash[:name]
    inv.tag_list = tag
    inv.save
  end
end

Given /^the following resource pages are tagged with "([^"]*)":$/ do |tag, table|
  table.hashes.each do |rp_hash|
    page = ResourcePage.find_by_name rp_hash[:name]
    page.tag_list = tag
    page.save
  end
end
