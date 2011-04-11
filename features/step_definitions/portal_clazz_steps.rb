Given /^the class "([^"]*)" has the class word "([^"]*)"$/ do |class_name, class_word|
  clazz = Portal::Clazz.find_by_name(class_name)
  clazz.class_word = class_word
  clazz.grade_levels << Factory(:full_portal_grade_level)
  clazz.save
end

Then /^the portal class "([^"]*)" should have been created$/ do |clazz_name|
  clazz = Portal::Clazz.find_by_name clazz_name
  clazz.should be
end

Then /^the class word for the portal class "([^"]*)" should be "([^"]*)"$/ do |clazz_name, class_word|
  clazz = Portal::Clazz.find_by_name clazz_name
  clazz.class_word.should == class_word
end

#Then /^I should be on the class edit page for "([^"]*)"$/ do |name|
  #clazz = Portal::Clazz.find_by_name(name)
  #current_path = URI.parse(current_url).path
  #expected = edit_portal_clazz_path(clazz)
  #if current_path.respond_to? :should
    #current_path.should == expected
  #else
    #assert_equal expected, current_path
  #end
#end


#When /^I visit the class page for "([^"]*)"$/ do |name|
  ## find out if the current user has a school....
  #clazz = Portal::Clazz.find_by_name(name)
  #visit portal_clazz_path(clazz)
#end


