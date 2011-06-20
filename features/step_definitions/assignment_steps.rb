def assign_runnable(runnable_element)
  drop = find("#clazz_offerings")
  scroll_into_view("#clazz_offerings")
  runnable_element.drag_to(drop)
  # TODO: Eliminate sleep() call.
  # Problem is that selenium is not waiting for callback to finish
  sleep(2)
end

def polymorphic_assign(assignable_type, assignable_name, clazz_name)
  clazz = Portal::Clazz.find_by_name(clazz_name)
  assignable = assignable_type.gsub(/\s/, "_").classify.constantize.find_by_name(assignable_name)
  assignable.should_not be_nil
  Factory.create(:portal_offering, {
    :runnable => assignable,
    :clazz => clazz
  })
end

Given /^the following assignments exist:$/ do |assignments_table|
  assignments_table.hashes.each do |hash|
    type = hash['type']
    name = hash['name']
    clazz_name = hash['class']
    polymorphic_assign(type, name, clazz_name)
  end  
end

Given /^the ([^"]+) "([^"]*)" is assigned to the class "([^"]*)"$/ do |assignable_type, assignable_name, class_name|
  polymorphic_assign(assignable_type, assignable_name, class_name)  
end

# this is the interactive version of the step above
When /^I assign the ([^"]+) "([^"]*)" to the class "([^"]*)"$/ do |assignable_type, assignable_name, class_name|
  assignable = assignable_type.gsub(/\s/, "_").classify.constantize.find_by_name(assignable_name)
  runnable_element = find("##{dom_id_for(assignable)}")
  assign_runnable(runnable_element)
end
