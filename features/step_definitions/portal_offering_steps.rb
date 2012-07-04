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

      save_result = investigation.save
      if (save_result == false)
        return save_result
      end
      
      myclazz = Portal::Clazz.find_by_name(hash['class'])
      offering = Portal::Offering.new
      offering.runnable_id = investigation.id
      offering.clazz_id = myclazz.id
      offering.runnable_type = 'Investigation'
      save_result = offering.save
      if (save_result == false)
        return save_result
      end
    end 
end

