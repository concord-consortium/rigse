Given /^the following external activit(?:y|ies) exist[s]?:$/ do |activity_table|
  activity_table.hashes.each do |hash|
    user = User.first(:conditions => { :login => hash.delete('user') })
    hash[:user_id] = user.id
    activity = Factory :external_activity, hash
    activity.publish
    activity.save
  end
end

When /^I drag the external activity "([^"]*)" to "([^"]*)"$/ do |activity_name, to|
  activity = ExternalActivity.find_by_name activity_name
  selector_id = "#external_activity_#{activity.id}"
  selector = find(selector_id)
  # NP 2011-09 see support/drag_and_drop.rb
  #
  # TODO: When Selenium issue ( http://bit.ly/q9LHR4 ) closes 
  # use the actual dragging code which we replaced
  #
  # drop = find(to)
  # selector.drag_to(drop)
  fake_drop("external_activity_#{activity.id}",to)
end

Then /^the learner count for the external activity "([^"]*)" in the class "(.*)" should be "(\d+)"$/ do |ea_name, class_name, learner_count|
  clazz = Portal::Clazz.find_by_name(class_name)
  activity = ExternalActivity.find_by_name(ea_name)
  offering = Portal::Offering.find_by_clazz_id_and_runnable_id(clazz.id, activity.id)
  offering.learners.size.should == learner_count.to_i
end
