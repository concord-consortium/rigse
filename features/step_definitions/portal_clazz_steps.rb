Given /^the class "([^"]*)" has the class word "([^"]*)"$/ do |class_name, class_word|
  clazz = Portal::Clazz.find_by_name(class_name)
  clazz.class_word = class_word
  clazz.grade_levels << Factory(:full_portal_grade_level)
  clazz.save
end

#When /^I visit the class page for "([^"]*)"$/ do |name|
  ## find out if the current user has a school....
  #clazz = Portal::Clazz.find_by_name(name)
  #visit portal_clazz_path(clazz)
#end


