=begin
Given /^I go to edit page for "(.+)"$/ do |class_name|
  click_link(class_name)
  click_link('edit class information')
end
=end
When /^I fill in Class Name with "(.+)"$/ do |className|
  fill_in('portal_clazz_name', :with => className)
end

And /^I include a teacher named "(.+)"$/ do |teacher_name|
  find(:xpath, '//a[@id="AddTeacher"]').click
  check('Einstien, Albert')
  click_button('AddTeacherSaveButton')
end

And /^I fill Description with "(.+)"$/ do |description|
  fill_in('portal_clazz_description' , :with => description)
end

And /^I fill Class Word with "([a-zA-Z0-9]+)"$/ do |classWord|
  fill_in('portal_clazz_class_word' , :with => classWord)
end

And /^I select Term "([A-Z]{1}[a-z]+)" from the drop down$/ do |term|
  select(term , :from => 'portal_clazz_semester_id')
end

And /^I uncheck investigation with label "(.+)"$/ do |investigation_name|
  uncheck(investigation_name)
end

And /^I move investigation named "(.+)" to the top of the list$/ do |investigation_name|
  page.execute_script(
                      "
                      
                       var sortableList = document.getElementById('sortable');
                       var arrListChildren = sortableList.getElementsByTagName('li');
                       var offeringToMove;
                       for(var i=0; i< arrListChildren.length; i++)
                       {
                          if(arrListChildren[i].innerHTML.stripTags().strip().toLowerCase() == \"#{investigation_name}\".toLowerCase())
                          {
                            offeringToMove = arrListChildren[i];
                            break;
                          }
                       }
                       var listFirstChild = arrListChildren[0]; 
                       if(offeringToMove && offeringToMove != listFirstChild)
                       {
                        sortableList.removeChild(offeringToMove);
                        sortableList.insertBefore(offeringToMove,listFirstChild);
                       }
                       
                       "
                     )
 
end

Then /^new data for the class should be saved$/ do
  page.should have_content('Class was successfully updated.')
end


And /^the following offerings exist$/ do |offering_table|
    offering_table.hashes.each do |hash|
      investigation = Factory(:investigation)
      investigation.name = hash['name']
      investigation.save!
      myclazz = Portal::Clazz.find_by_name('My Class')
      @offering = Portal::Offering.new
      @offering.runnable_id = investigation.id
      @offering.clazz_id = myclazz.id
      @offering.runnable_type = 'Investigation'
      @offering.save!
    end
end


And /^the first investigation in the list should be "(.+)"$/ do |investigation_name|
  result = page.execute_script(
                                "
                                 var bSortSuccess = false;
                                 var arrListItems = Prototype.Selector.select('ul.quiet_list>li');
                                 var firstChild = arrListItems[0];
                                 var strLinkText = firstChild.innerHTML.stripTags().strip().toLowerCase().replace('run ','')
                                 if(strLinkText == \"#{investigation_name}\".toLowerCase())
                                 {
                                    bSortSuccess = true;
                                 }
                                 
                                 return bSortSuccess; 
                                "
                               )
 raise 'Not first on the list' if result == false
end