Given /^the following empty investigations exist:$/ do |table|
  table.hashes.each do |hash|
    user = User.find_by_login hash['user']
    Factory.create(:investigation, hash.merge('user' => user))
  end
end

Given /^the following simple investigations exist:$/ do |investigation_table|
  investigation_table.hashes.each do |hash|
    user = User.first(:conditions => { :login => hash.delete('user') })
    hash[:user_id] = user.id
    investigation = Investigation.create(hash)
    activity = Activity.create(hash)
    section = Section.create(hash)
    page = Page.create(hash)
    section.pages << page
    activity.sections << section
    investigation.activities << activity
    investigation.save
  end
end

#Table: | investigation | activity | section   | page   | multiple_choices |
Given /^the following investigations with multiple choices exist:$/ do |investigation_table|
  investigation_table.hashes.each do |hash|
    investigation = Investigation.find_or_create_by_name(hash['investigation'])
    investigation.user = Factory(:user)
    investigation.save
    # ITSISU requires descriptions on activities
    activity = Activity.find_or_create_by_name(hash['activity'], :description => hash['activity'])
    section = Section.find_or_create_by_name(hash['section'])
    page = Page.find_or_create_by_name(hash['page'])
    mcs = hash['multiple_choices'].split(",").map{ |q| Embeddable::MultipleChoice.find_by_prompt(q.strip) }
    mcs.each do |q|
      q.pages << page
    end
    imgqs = hash['image_questions'].split(",").map{ |q| Embeddable::ImageQuestion.find_by_prompt(q.strip) }
    imgqs.each do |q|
      q.pages << page
    end
    page.save
    section.pages << page
    activity.sections << section
    investigation.activities << activity
  end
end

Given /^the following classes exist:$/ do |table|
  table.hashes.each do |hash|
    if hash['teacher']
      user = User.find_by_login hash['teacher']
      teacher = user.portal_teacher
    else
      teacher = Factory(:teacher)
    end
    Factory.create(:portal_clazz, hash.merge('teacher' => teacher))
  end
end

Given /^the investigation "([^"]*)" is published$/ do |investigation_name|
  investigation = Investigation.find_by_name investigation_name
  investigation.publish
  investigation.save
end

When /^I sort investigations by "([^"]*)"$/ do |sort_str|
  visit "/investigations?sort_order=#{sort_str}"
end

When /^I drag the investigation "([^"]*)" to "([^"]*)"$/ do |investigation_name, to|
  investigation = Investigation.find_by_name investigation_name
  selector = find("#investigation_#{investigation.id}")
  drop = find(to)
  selector.drag_to(drop)
end

When /^I show offerings count on the investigations page$/ do 
  visit "/investigations?include_usage_count=true"
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


#Then /^"([^\"]*)" should have ([0-9]+) "([^\"]*)"$/ do |selector1, count, selector2|
  #within(selector1) do |content|
       #content.should have_selector(selector2, :count => count.to_i)
  #end
#end


Then /^There should be (\d+) (?:investigations|assignables) displayed$/ do |count|
  within("#offering_list") do
    page.all(".runnable").size.should == count.to_i
  end
end

Then /^"([^"]*)" should not be displayed in the (?:investigations|assignables) list$/ do |not_expected|
  within("#offering_list") do 
    page.should have_no_content(not_expected)
  end
end

Then /the following should (not )?be displayed in the (?:investigations|assignables) list:$/ do |nomatch, table|
  within('#assignable_list') do
    table.hashes.each do |hash|
      if nomatch == "not "
        page.should have_no_content(hash[:name])
      else
        page.should have_content(hash[:name])
      end
    end
  end
end

When /^I click on the next page of results$/ do
  within('.pagination') do
    click_link('Next')
  end
end

When /^I browse draft investigations$/ do
  visit "/investigations?include_drafts=true"
end

Then /^"([^"]*)" should be displayed in the investigations list$/ do |expected|
  within("#offering_list") do 
    page.should have_content(expected)
  end
end

When /^I enter "([^"]*)" in the search box$/ do |search_string|
  within('#investigation_search_form') do
    fill_in 'name', :with => search_string
  end
end

Then /^every investigation should contain "([^"]*)"$/ do |expected|
  within("#offering_list") do
    page.all(".runnable").each do |piece|
      piece.should have_content(expected)
    end
  end
end
# This step doesnt work, left for reference.
#When /^I wait for the search spinner to be hidden/ do
  ## wait for the spinner to show up, and then to go away again
  ## This is sooo lame, but I coulnd't get the other techniques (below)
  ## to work, and was running out of time
  ##page.wait_until { (page.evaluate_script("$('search_spinner').visible()") == false) }
  #page.has_css?("#offering_list", :visible =>true)
  #page.has_css?("#search_spinner",:visible =>true)
  #page.has_css?("#search_spinner",:visible =>false)
#end
#
When /^I wait for all pending requests to complete/ do
  # kind of a hack until the automatic junk in capybara starts to work
  begin
    page.wait_until { true == page.evaluate_script("PendingRequests > 0;")}
  rescue Capybara::TimeoutError
    puts "PendingRequests was zero"
  end
  page.wait_until(5) { true == page.evaluate_script("PendingRequests == 0;")}
end

Then /^the investigation "([^"]*)" should have been created$/ do |inv_name|
  investigation = Investigation.find_by_name inv_name
  investigation.should be
end

Then /^the investigation "([^"]*)" should have an offerings count of (\d+)$/ do |inv_name, count|
  investigation = Investigation.find_by_name inv_name
  investigation.offerings_count.should == count.to_i
end

def show_actions_menu
  # this requires a javascript enabled driver
  # this simulates roughly what happens when the mouse is moved over the plus icon

  # this first part is what happens in the onmouseover event on the gear icon
  # it is necessary to call first because it positions the menu relative to the gear icon
  # it also adds listeners to make the menu show up, but we aren't using them since we 
  # aren't really moving the mouse.
  page.execute_script("dropdown_for('button_actions_menu','actions_menu')")

  # now that the menu is positioned we can just manually show it
  page.execute_script("$('actions_menu').show()")
end

When /^I duplicate the investigation$/ do
  show_actions_menu
  click_link("duplicate")
  page.execute_script("$('actions_menu').hide()")
end

Then /^I cannot duplicate the investigation$/ do
  show_actions_menu
  page.should have_no_content('duplicate')
end
