Given(/^the following Admin::tag records exist:$/) do |admin_tag_table|
  admin_tag_table.hashes.each do |hash|
    Factory(:admin_tag, hash)
  end
end


When(/^under "(.*?)" I check "(.*?)"$/) do |scope, tag|
  check(tag)
end

When(/^under "(.*?)" I choose "(.*?)"$/) do |scope, tag|
  choose(tag)
end

When(/^under "(.*?)" I uncheck "(.*?)"$/) do |scope, tag|
  uncheck(tag)
end

When /^(?:|I )create interactive "(.+)" before "(.+)" by date$/ do |interactive_name1, interactive_name2|
  created_at = Date.today
  [interactive_name1, interactive_name2].each do |interactive|
    inv = Interactive.find_or_create_by_name(interactive)
    created_at = created_at - 1
    inv.created_at = created_at
    inv.updated_at = created_at
    inv.save!
  end
end

When(/^I check "(.*?)" under "(.*?)" filter$/) do |filter, filter_header|
  check("#{filter_header.singularize}_#{filter}".downcase.tr(" ","_"))
end

When(/^I uncheck "(.*?)" under "(.*?)" filter$/) do |filter, filter_header|
  uncheck("#{filter_header.singularize}_#{filter}".downcase.tr(" ","_"))
end

When(/^I select "(.*?)" under "(.*?)" filter$/) do |filter, filter_header|
  select filter, :from => filter_header.downcase.tr(" ","_")
end

