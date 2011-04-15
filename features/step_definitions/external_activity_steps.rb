Given /^the following external activity exists:$/ do |activity_table|
  activity_table.hashes.each do |hash|
    user = User.first(:conditions => { :login => hash.delete('user') })
    hash[:user_id] = user.id
    activity = Factory :external_activity, hash
    activity.publish
    activity.save
  end
end

Given /^the external activity "([^"]*)" is assigned to the class "([^"]*)"$/ do |activity_name, class_name|
  clazz = Portal::Clazz.find_by_name(class_name)
  activity = ExternalActivity.find_by_name(activity_name)
  Factory.create(:portal_offering, {
    :runnable => activity,
    :clazz => clazz
  })
end
  
When /^I assign the external activity "([^"]*)" to the class "([^"]*)"$/ do |activity_name, class_name|
  clazz = Portal::Clazz.find_by_name(class_name)
  activity = ExternalActivity.find_by_name(activity_name)
  Factory.create(:portal_offering, {
    :runnable => activity,
    :clazz => clazz
  })
end

# this is the interactive version of the step above
When /^I assign the external activity "([^"]*)"$/ do |activity_name|
  activity = ExternalActivity.find_by_name activity_name
  runnable_element = find("#external_activity_#{activity.id}")
  assign_runnable(runnable_element)
end

When /^I drag the external activity "([^"]*)" to "([^"]*)"$/ do |activity_name, to|
  activity = ExternalActivity.find_by_name activity_name
  selector = find("#external_activity_#{activity.id}")
  drop = find(to)
  selector.drag_to(drop)
end

Then /^the learner count for the external activity "([^"]*)" in the class "(.*)" should be "(\d+)"$/ do |ea_name, class_name, learner_count|
  clazz = Portal::Clazz.find_by_name(class_name)
  activity = ExternalActivity.find_by_name(ea_name)
  offering = Portal::Offering.find_by_clazz_id_and_runnable_id(clazz.id, activity.id)
  offering.learners.size.should == learner_count.to_i
end
