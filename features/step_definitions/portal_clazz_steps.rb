Given /^the class "([^"]*)" has the class word "([^"]*)"$/ do |class_name, class_word|
  clazz = Portal::Clazz.find_by_name(class_name)
  clazz.class_word = class_word
  clazz.grade_levels << Factory(:full_portal_grade_level)
  clazz.save
end

Given /^the class "([^"]*)" is the default class$/ do |class_name|
  clazz = Portal::Clazz.find_by_name class_name
  clazz.default_class = true
  clazz.save
end

Then /^I should see "([^"]*)" for the external activity "([^"]*)"$/ do |content, offering_name|
  offering = ExternalActivity.find_by_name offering_name
  with_scope("#details_portal__offering_#{offering.id}") do
    page.should have_content(content)
  end
end
