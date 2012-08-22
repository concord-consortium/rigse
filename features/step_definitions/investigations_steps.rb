Given /^the following empty investigations exist:$/ do |table|
  table.hashes.each do |hash|
    user = User.find_by_login hash['user']
    Factory.create(:investigation, hash.merge('user' => user))
  end
end

Given /^the following linked investigations exist:$/ do |table|
  table.hashes.each do |hash|
    user = User.find_by_login hash['user']
    inv = Factory.create(:investigation, hash.merge('user' => user))
      inv.activities << (Factory :activity, { :user => user })
      inv.activities[0].sections << (Factory :section, {:user => user})
      inv.activities[0].sections[0].pages << (Factory :page, {:user => user})
      open_response = (Factory :open_response, {:user => user})
      open_response.pages << inv.activities[0].sections[0].pages[0]
      draw_tool = (Factory :drawing_tool, {:user => user, :background_image_url => "https://lh4.googleusercontent.com/-xcAHK6vd6Pc/Tw24Oful6sI/AAAAAAAAB3Y/iJBgijBzi10/s800/4757765621_6f5be93743_b.jpg"})
      draw_tool.pages << inv.activities[0].sections[0].pages[0]
      snapshot_button = (Factory :lab_book_snapshot, {:user => user, :target_element => draw_tool})
      snapshot_button.pages << inv.activities[0].sections[0].pages[0]
      prediction_graph = (Factory :data_collector, {:user => user})
      prediction_graph.pages << inv.activities[0].sections[0].pages[0]
      displaying_graph = (Factory :data_collector, {:user => user, :prediction_graph_source => prediction_graph})
      displaying_graph.pages << inv.activities[0].sections[0].pages[0]
      inv.reload
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

Given /^the author "([^"]*)" created an investigation named "([^"]*)" with text and a open response question$/ do |author, name|
  user = User.first(:conditions => { :login => author })
  hash = {:user_id => user.id, :name => name}
  investigation = Investigation.create(hash)
  activity = Activity.create(hash)
  section = Section.create(hash)
  page = Page.create(hash)
  section.pages << page
  activity.sections << section
  investigation.activities << activity
  page.add_embeddable(Embeddable::Xhtml.create(hash))
  page.add_embeddable(Embeddable::OpenResponse.create(hash))
  page.save
  investigation.save
end

#Table: | investigation | activity | activity_teacher_only | section   | page   | multiple_choices |
Given /^the following investigations with multiple choices exist:$/ do |investigation_table|
  investigation_table.hashes.each do |hash|
    investigation = Investigation.find_or_create_by_name(hash['investigation'])
    investigation.user = Factory(:user)
    investigation.save
    # ITSISU requires descriptions on activities
    activity = Activity.find_or_create_by_name(hash['activity'], :description => hash['activity'])
    
    if hash['activity_teacher_only']
      # Create a teacher only activity if specified
      activity.teacher_only = (hash['activity_teacher_only'] == 'true')
      activity.save
    end
    
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

Given /^the following semesters exist:$/ do|semesters_table|
   semesters_table.hashes.each do |hash|
     Factory.create(:portal_semester, hash)
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
    hash.merge!('teacher' => teacher)
    
    if !(hash['semester'].nil?) then
      semester = Portal::Semester.find_by_name(hash['semester']);
      if (semester.nil?) then
        semester = Factory.create(:portal_semester, :name => hash['semester']);
      end
      hash.merge!('semester' => semester);
    end
    
    Factory.create(:portal_clazz, hash)
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

When /sort order .*should be "([^"]*)"/ do |sort_str|
  page.should have_selector('select[name="[sort_order]"]')
  page.should have_selector("option[value='#{sort_str}'][selected='selected']")
end

When /^I drag the investigation "([^"]*)" to "([^"]*)"$/ do |investigation_name, to|
  investigation = Investigation.find_by_name investigation_name
  selector_id = "#investigation_#{investigation.id}"
  selector = find(selector_id)
  drop = find(to)
  # NP 2011-09 see support/drag_and_drop.rb
  # TODO: When Selenium issue ( http://bit.ly/q9LHR4 ) closes 
  # use the actual dragging code which we replaced
  #
  # selector.drag_to(drop)
  fake_drop(selector_id,to)
end


Then /^I should not see the "([^"]*)" checkbox in the list filter$/ do |arg1|
  page.should_not have_selector("input[name='#{arg1}'][type='checkbox']")
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
  # NP 2011-09 see support/drag_and_drop.rb
  # TODO: When Selenium issue ( http://bit.ly/q9LHR4 ) closes 
  # use the actual dragging code which we replaced
  #
  # find(selector).drag_to(find(to))
  
  fake_drop(selector,to)
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

When /^I browse public investigations$/ do
  visit "/investigations"
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

Then /^the investigation "([^"]*)" should have correct linked prediction graphs/ do |inv_name|
  copy = Investigation.find_by_name inv_name
  orig = Investigation.find_by_name inv_name.gsub(/^copy of /, '')

  orig_prediction_graph = orig.pages.first.data_collectors.first
  copy_prediction_graph = copy.pages.first.data_collectors.first

  orig_dc = orig.pages.first.data_collectors.last
  copy_dc = copy.pages.first.data_collectors.last

  copy_dc.prediction_graph_source.should == copy_prediction_graph
end

Then /^the investigation "([^"]*)" should have correct linked snapshot buttons/ do |inv_name|
  copy = Investigation.find_by_name inv_name
  orig = Investigation.find_by_name inv_name.gsub(/^copy of /, '')

  orig_draw_tool = orig.pages.first.drawing_tools.first
  copy_draw_tool = copy.pages.first.drawing_tools.first

  orig_snap = orig.pages.first.lab_book_snapshots.first
  copy_snap = copy.pages.first.lab_book_snapshots.first

  copy_snap.target_element.should == copy_draw_tool
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

And /^the investigation "([^"]*)" with activity "([^"]*)" belongs to domain "([^"]*)" and has grade "([^"]*)"$/ do |investigation_name, activity_name, domain_name, grade_value|
  @domain = Factory.create( :rigse_domain, { :name => domain_name } )
  knowledge_statement = Factory.create( :rigse_knowledge_statement, { :domain => @domain } )
  assessment_target = Factory.create( :rigse_assessment_target, { :knowledge_statement => knowledge_statement })
  
  @grade = grade_value
  grade_span_expection  = Factory.create( :rigse_grade_span_expectation, {:assessment_target => assessment_target, :grade_span => @grade} )
  
  investigation = 
    {
      :name => investigation_name,
      :grade_span_expectation => grade_span_expection
    }
      
  @published = []
  @drafts = []
  
  published = Factory.create(:investigation, investigation)
  published.name << " (published) "
  published.publish!
  published.save
  @published << published.reload
  Factory.create(:activity, :investigation_id => published.id , :name => activity_name)
  draft = Factory.create(:investigation, investigation)
  draft.name << " (draft) "
  draft.save
  @drafts << draft.reload
  
end

And /^the investigation "([^"]*)" with activity "([^"]*)" belongs to probe "([^"]*)"$/ do |investigation_name, activity_name, probe_name|
  
  domain_name = "random domain"
  
  @domain = Factory.create( :rigse_domain, { :name => domain_name } )
  knowledge_statement = Factory.create( :rigse_knowledge_statement, { :domain => @domain } )
  assessment_target = Factory.create( :rigse_assessment_target, { :knowledge_statement => knowledge_statement })
  
  @grade = "10-11"
  grade_span_expection  = Factory.create( :rigse_grade_span_expectation, {:assessment_target => assessment_target, :grade_span => @grade} )
  
  
  @probe_type = Probe::ProbeType.find_by_name(probe_name)
  unless @probe_type
    @probe_type = Factory.create(:probe_type, :name => probe_name)
    @probe_type.save!
  end
  
  investigation_hash = {
    :name => investigation_name,
    :grade_span_expectation => grade_span_expection
  }
  
  investigation = Factory.create(:investigation, investigation_hash)
  investigation.publish
  investigation.save!
  
  @probe_activity = Factory.create(:activity, :investigation_id => investigation.id, :name => activity_name)
  @probe_activity.save!
  
  section = Factory.create(:section,:activity_id => @probe_activity.id)
  section.save!
  page = Factory.create(:page, :section => section)
  page.save!
  
  page_element = PageElement.new
  page_element.id = 1
  page_element.page = page
  page_element.embeddable_type = 'Embeddable::DataCollector'
  page_element.save!
  
  embeddable_data_collectors = Factory.create(:data_collector)
  
  page_element.embeddable = embeddable_data_collectors
  page_element.save!
  
  embeddable_data_collectors.probe_type = @probe_type
  embeddable_data_collectors.save!
  
end