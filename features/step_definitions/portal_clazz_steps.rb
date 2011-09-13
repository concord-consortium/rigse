Given /^the class "([^"]*)" has the class word "([^"]*)"$/ do |class_name, class_word|
  clazz = Portal::Clazz.find_by_name(class_name)
  clazz.class_word = class_word
  clazz.grade_levels << Factory(:portal_grade_level)
  clazz.save
end

Given /^the default class is created$/ do
  enabled_default_class(true)
  # this has the side effect of creating the default class if it doesn't already exist
  Portal::Clazz.default_class
end

Then /^I should see "([^"]*)" for the external activity "([^"]*)"$/ do |content, offering_name|
  offering = ExternalActivity.find_by_name offering_name
  with_scope("#details_portal__offering_#{offering.id}") do
    page.should have_content(content)
  end
end

Then /^the class "([^"]*)" should not have any offerings$/ do |class_name|
  clazz = Portal::Clazz.find_by_name class_name
  clazz.offerings.size.should == 0
end

Then /^the classes "([^"]*)" are in a school named "([^"]*)"$/ do |classes,school_name|
  school = Factory(:portal_school, :name=>school_name)
  classes = classes.split(",").map { |t| t.strip }
  classes.map! {|t| Portal::Clazz.find_by_name(t)}
  classes.each {|t| t.course.school =  school; t.course.save!; t.reload; }
end

Then /^the portal class "([^"]*)" should have been created$/ do |clazz_name|
  clazz = Portal::Clazz.find_by_name clazz_name
  clazz.should be
end

Then /^the class word for the portal class "([^"]*)" should be "([^"]*)"$/ do |clazz_name, class_word|
  clazz = Portal::Clazz.find_by_name clazz_name
  clazz.class_word.should == class_word
end
