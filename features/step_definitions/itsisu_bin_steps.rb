When /^I click the bin named "([^"]*)"$/ do |arg1|
  # TODO:
  # don't know how to do this...
end

When /^I check the activity "([^"]*)" in the bin view$/ do |activity_name|
  with_scope("div:contains('#{activity_name}')") do
    check("runnable_id")
  end
end

When /^I uncheck the activity "([^"]*)" in the bin view$/ do |activity_name|
  with_scope("div:contains('#{activity_name}')") do
    uncheck("runnable_id")
  end
end
