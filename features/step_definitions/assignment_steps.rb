def assign_runnable(runnable_element)
  drop_id = "#clazz_offerings"
  drop = find(drop_id)
  # NP 2011-09
  #
  # TODO: When Selenium issue ( http://bit.ly/q9LHR4 ) closes 
  # simulate the drag event like this:
  # 
  # scroll_into_view(drop_id)
  # find("##{runnable_element}").drag_to(drop)
  # sleep(2) # TODO: eliminate sleep call
  fake_drop(runnable_element,drop_id);
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
  assignable_id = dom_id_for(assignable)
  assign_runnable(assignable_id)
  with_scope("#clazz_offerings") do
    # this isn't the best approach but it might be good enough for now
    page.should have_content(assignable_name)
  end
end
