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

And /^the following offerings exist in the classes:$/ do |offering_list|
    offering_list.hashes.each do |hash|
      investigation = Factory(:investigation)
      investigation.name = hash['name']

      investigation.save!
      
      myclazz = Portal::Clazz.find_by_name(hash['class'])
      offering = Portal::Offering.new
      offering.runnable = investigation
      offering.clazz = myclazz
      offering.save!
    end 
end

Given /^the following default class offerings exist$/ do |offering_list|
    offering_list.hashes.each do |hash|
      investigation = Factory(:investigation, :publication_status => "published")
      investigation.name = hash['name']

      investigation.save!

      offering = Portal::Offering.new
      offering.clazz_id = Portal::Clazz.default_class.id
      offering.runnable = investigation
      offering.default_offering = true
      offering.save!
    end
end