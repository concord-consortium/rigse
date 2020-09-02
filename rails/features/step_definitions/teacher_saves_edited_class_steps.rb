
When /^I fill in Class Name with "(.+)"$/ do |className|
  fill_in('portal_clazz_name', :with => className)
end

And /^I fill Description with "(.+)"$/ do |description|
  fill_in('portal_clazz_description' , :with => description)
end

And /^I fill Class Word with "([a-zA-Z0-9]+)"$/ do |classWord|
  fill_in('portal_clazz_class_word' , :with => classWord)
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

And /^the following offerings exist$/ do |offering_table|
    offering_table.hashes.each do |hash|
      investigation = FactoryBot.create(:investigation)
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

When /^(?:I )follow remove image for the teacher name "(.*)"$/ do |teacher_name|
  step_text = "follow xpath \"//li[contains(., '#{teacher_name}')]/span[@class='rollover']\""
  step step_text
end

Then /^I should not see the remove image for the teacher name "(.*)"$/ do |teacher_name|
  expect(page).to have_no_xpath "//li[contains(., '#{teacher_name}')]/span[@class='rollover']"
end

Then /^"([^"]*)" should( not)? be a teacher option$/ do |value, negate|
  expectation = negate ? :should_not : :should
  find("#teacher_id_selector").first(:xpath, ".//option[text() = '#{value}']").send(expectation, be_present)
end

