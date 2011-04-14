Then /^the external activity offering "([^"]*)" in the class "([^"]*)" should be a default offering$/ do |ea_name, class_name|
  ea = ExternalActivity.find_by_name ea_name
  clazz = Portal::Clazz.find_by_name class_name
  offering = Portal::Offering.find_by_runnable_id_and_clazz_id ea.id, clazz.id
  offering.default_offering.should == true
end

Then /^the external activity offering "([^"]*)" in the class "([^"]*)" should not be a default offering$/ do |ea_name, class_name|
  ea = ExternalActivity.find_by_name ea_name
  clazz = Portal::Clazz.find_by_name class_name
  offering = Portal::Offering.find_by_runnable_id_and_clazz_id ea.id, clazz.id
  offering.default_offering.should == false
end

def assign_runnable(runnable_element)
  drop = find("#clazz_offerings")
  scroll_into_view("#clazz_offerings")
  runnable_element.drag_to(drop)
  # TODO: Eliminate sleep() call.
  # Problem is that selenium is not waiting for callback to finish
  sleep(2)
end
