# This is a slightly different method than the one in the authoring_steps.rb file
# This one uses factories, whereas the other builds a valid Investigation from scratch
Given /^the following investigations exist:$/ do |table|
  table.hashes.each do |hash|
    user = User.find_by_login hash['user']
    Factory.create(:investigation, hash.merge('user' => user))
  end
end

Given /^the following classes exist:$/ do |table|
  table.hashes.each do |hash|
    user = User.find_by_login hash['teacher']
    teacher = user.portal_teacher
    Factory.create(:portal_clazz, hash.merge('teacher' => teacher))
  end
end

When /^I sort investigations by "([^"]*)"$/ do |sort_str|
  visit "/investigations?sort_order=#{sort_str}"
end

When /^I show offerings count on the investigations page$/ do 
  visit "/investigations?include_usage_count=true"
end

When /^I assign the investigation "([^"]*)" to the class "([^"]*)"$/ do |investigation_name, class_name|
  clazz = Portal::Clazz.find_by_name(class_name)
  investigation = Investigation.find_by_name(investigation_name)
  Factory.create(:portal_offering, {
    :runnable => investigation,
    :clazz => clazz
  })
end

When /^I remove the investigation "([^"]*)" from the class "([^"]*)"$/ do |investigation_name, class_name|
  clazz = Portal::Clazz.find_by_name(class_name)
  investigation = Investigation.find_by_name(investigation_name)
  offering = Portal::Offering.first(:conditions => {
    :runnable_type => investigation.class.name,
    :runnable_id => investigation.id,
    :clazz_id => clazz.id
  })
  visit "/portal/classes/#{clazz.id}/remove_offering?offering_id=#{offering.id}"
end


When /^I follow "(.*)" on the (.*) "(.*)" from the class "(.*)"$/ do |button_name, model_name, obj_name, class_name|
  the_class = model_name.gsub(/\s/, '_').singularize.classify.constantize
  clazz = Portal::Clazz.find_by_name(class_name)
  obj = the_class.find_by_name(obj_name)
  offering = Portal::Offering.first(:conditions => {
    :runnable_type => obj.class.name,
    :runnable_id => obj.id,
    :clazz_id => clazz.id
  })
  
  selector = "#portal__offering_#{offering.id}"
  with_scope(selector) do
    click_link(button_name)
  end
end

When /^a student has performed work on the investigation "([^"]*)" for the class "([^"]*)"$/ do |investigation_name, class_name|
  clazz = Portal::Clazz.find_by_name(class_name)
  investigation = Investigation.find_by_name(investigation_name)
  offering = Portal::Offering.first(:conditions => {
    :runnable_type => investigation.class.name,
    :runnable_id => investigation.id,
    :clazz_id => clazz.id
  })
  Factory.create(:full_portal_learner, :offering => offering)
end

When /^I open the accordion for the offering for investigation "([^"]*)" for the class "([^"]*)"$/ do |investigation_name, class_name|
  clazz = Portal::Clazz.find_by_name(class_name)
  investigation = Investigation.find_by_name(investigation_name)
  offering = Portal::Offering.first(:conditions => {
    :runnable_type => investigation.class.name,
    :runnable_id => investigation.id,
    :clazz_id => clazz.id
  })
  selector = "#_toggle_portal__offering_#{offering.id}"
  find(selector).click
end


When /^I drag the investigation "([^"]*)" in the class "(.*)" to "([^"]*)"$/ do |investigation_name, class_name, to|
  clazz = Portal::Clazz.find_by_name(class_name)
  investigation = Investigation.find_by_name(investigation_name)
  offering = Portal::Offering.first(:conditions => {
    :runnable_type => investigation.class.name,
    :runnable_id => investigation.id,
    :clazz_id => clazz.id
  })
  selector = "#portal__offering_#{offering.id}"
  find(selector).drag_to(find(to))
end

Then /^the investigation "([^"]*)" in the class "(.*)" should be active$/ do |investigation_name, class_name|
  clazz = Portal::Clazz.find_by_name(class_name)
  investigation = Investigation.find_by_name(investigation_name)
  offering = Portal::Offering.first(:conditions => {
    :runnable_type => investigation.class.name,
    :runnable_id => investigation.id,
    :clazz_id => clazz.id
  })
  offering.should be_active
end

