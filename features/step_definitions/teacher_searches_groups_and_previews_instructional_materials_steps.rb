When /^the following activities for the above investigations exist:$/ do |activity_table|
  #the search data exists
  activity_table.hashes.each do |hash|
    investigation_name = hash.delete('investigation')
    investigation = Investigation.find_by_name(investigation_name)
    hash[:investigation_id] = investigation.id
    hash[:user] = User.find_by_login(hash[:user])
    activity = Activity.create(hash)
end
end

Then /^(?:|I )should preview investigation "(.+)" on the search instructional materials page$/ do |investigation_name|
    investigation_id = Investigation.find_by_name(investigation_name).id
    within(:xpath,"//div[@id = 'search_investigation_#{investigation_id}']") do
      step 'I follow "Preview"'
    end
    step 'I receive a file for download with a filename like "_investigation_"'
end

Then /^(?:|I )should preview activity "(.+)" on the search instructional materials page$/ do |activity_name|
    activity_id = Activity.find_by_name(activity_name).id
    within(:xpath,"//div[@id = 'search_activity_#{activity_id}']") do
      step 'I follow "Preview"'
    end
    step 'I receive a file for download with a filename like "_activity_"'
end

When /^(?:|I )search for "(.+)" on the search instructional materials page$/ do |search_text|
  step_text = "I fill in \"search_term\" with \"#{search_text}\""
  step step_text
  step 'I press "GO"'
  page.should have_content("matching search term \"#{search_text}\"")
end

When /^(?:|I )enter search text "(.+)" on the search instructional materials page$/ do |search_text|
  step_text = "I fill in \"search_term\" with \"#{search_text}\""
  step step_text
  step 'I should wait 2 seconds'
end

When /^(?:|I )should see search suggestions for "(.+)" on the search instructional materials page$/ do |search_text|
  step_text = "I should see \"#{search_text}\" within suggestion box"
  step step_text
end

When /^(?:|I )should see search results for "(.+)" on the search instructional materials page$/ do|search_text|
  step_text = "I should see \"#{search_text}\" within result box"
  step step_text
end

When /^(?:|I )follow "(.+)" in Sort By on the search instructional materials page$/ do |label_name|
  find(:xpath, "//label[contains(., '#{label_name}')]").click
  step 'I should wait 2 seconds'
end


Then /^the search results should be paginated on the search instructional materials page$/ do
  save_and_open_page
  #pagination for investigations  
  within(".results_container .materials_container.investigations") do
    if page.respond_to? :should
      page.should have_link("Next")
    else
      assert page.has_link?("Next")
    end
    
    page.should have_content("Previous")
    
    step 'I follow "Next"'
    if page.respond_to? :should
      page.should have_link("Previous")
    else
      assert page.has_link?("Previous")
    end
    
    page.should have_content("Next")
  end
  
  #pagination for activity
  step 'I am on the search instructional materials page'
  within(".results_container .materials_container.activities") do
    if page.respond_to? :should
      page.should have_link("Next")
    else
      assert page.has_link?("Next")
    end
    
    page.should have_content("Previous")
    
    step 'I follow "Next"'
    if page.respond_to? :should
      page.should have_link("Previous")
    else
      assert page.has_link?("Previous")
    end
    
    page.should have_content("Next")
  end
end

And /^(?:|I )follow the "(.+)" link for the (investigation|activity) "(.+)"$/ do |link, material_type, material_name|
  within(".materials_container.#{material_type.pluralize}") do
    # the following is a way to track down the div that contains all the information about this material
    # the first part might stop working if capybara is upgraded because newer capybara uses the devices css
    # matching system and 'contains' is not supported by all browsers.
    # a possibly better approach would be to make a custom selector that builds a single xpath selector from some
    # arguments. Or another approach is to add aria-label(by) to the top level div and search based on that
    material_name_span = find("span.material_header:contains(\"#{material_name}\")")
    material_item_div = material_name_span.first(:xpath, "ancestor-or-self::div[@class='material_list_item']")
    within(material_item_div) do
      step_text = "I follow \"#{link}\""
      step step_text
    end
  end
end

And /^(?:|I )follow (investigation|activity) link "(.+)" on the search instructional materials page$/ do |material_type, material_name|
  within(".materials_container.#{material_type.pluralize}") do
    click_link(material_name)
  end
end