Given /^The materials have been indexed$/ do
  reindex_all # see solr_spec_helper.rbs
end

Given /"(.+)" has been updated recently/ do |name|
  external_act = ExternalActivity.find_by_name(name)
  if external_act
    external_act.touch
    puts "updating #{external_act.class.name} #{name}"
  end
end

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

When /^(?:|I )search for "(.+)" on the search instructional materials page$/ do |search_text|
  fill_in("search_term", :with => search_text)
  click_button("Go")
  using_wait_time(10) do
    expect(page).to have_content("matching search term \"#{search_text}\"")
  end
end

When /^(?:|I )enter search text "(.+)" on the search instructional materials page$/ do |search_text|
  fill_in("search_term", :with => search_text)
  step 'I should wait 2 seconds'
end

When /^(?:|I )close the search suggestions$/ do
  find("#search_term").send_keys :escape
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
  find(:xpath, "//option[contains(., '#{label_name}')]").click
  step 'I should wait 2 seconds'
end


Then /^the search results should be paginated on the search instructional materials page$/ do
  #pagination for any material
  next_text = "Next"
  previous_text = "Previous"
  page.first(:css, ".search_resultscontainer .pagination a", text: next_text)
  step "I follow \"#{next_text}\""
  page.first(:css, ".search_resultscontainer .pagination a", text: previous_text)
end

And /^(?:|I )follow the "(.+)" link for the (investigation|activity) "(.+)"$/ do |link, material_type, material_name|
  material_item_div = first(:xpath, "//div[@class='materials_container #{material_type.pluralize}']//div[@data-material_name='#{material_name}']")
  within(material_item_div) do
    step_text = "I follow \"#{link}\""
    step step_text
  end
end

And /^(?:|I )follow (investigation|activity) link "(.+)" on the search instructional materials page$/ do |material_type, material_name|
  within(".materials_container.#{material_type.pluralize}") do
    # for some reason this is not always visible initially, the approach below will cause capybara's waiting
    # mechanism to kick in waiting for the element to become visible
    first('a', :text => material_name, :visible => true).click
  end
end

And /^(?:|I )follow the (investigation|activity) preview link for "(.+)" on the search instructional materials page$/ do |material_type, material_name|
  within(".materials_container.#{material_type.pluralize}") do
    # for some reason this is not always visible initially, the approach below will cause capybara's waiting
    # mechanism to kick in waiting for the element to become visible
    find('a', :text => material_name, :visible => true).click
  end
end
