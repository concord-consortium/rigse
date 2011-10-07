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

Then /^run the offering "([^"]*)"$/ do |runnable_name|
  with_scope("div.activity-title:contains(#{runnable_name})") do
    find(:css, "img[alt='Bullet_go']").click
  end
end

Given /^a student in "([^"]*)" has run the offering "([^"]*)"$/ do |clazz_name, runnable_name|
  # create a random student in the class
  clazz = Portal::Clazz.find_by_name clazz_name
  offering = clazz.offerings.to_a.find { |offering| offering.name == runnable_name }
  learner = Factory(:full_portal_learner, :offering => offering)
end
