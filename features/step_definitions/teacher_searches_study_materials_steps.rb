When /^the following activities for the above investigations exist:$/ do |activity_table|
  activity_table.hashes.each do |hash|
    investigation_name = hash.delete('investigation')
    investigation = Investigation.find_by_name(investigation_name)
    hash[:investigation_id] = investigation.id
    hash[:user] = User.find_by_login(hash[:user])
    activity = Activity.create(hash)
    investigation.activities << activity
  end
end

When /^I enter search text "(.+)"$/ do |search_text|
  step_text =  'I fill in "search_term" with "'+search_text+'"'
  step step_text
end

When /^I should see search suggestions for "(.+)"$/ do|search_text|
  step_text =  'I should see "'+search_text+'" within suggestion box'
  step step_text
end

When /^I search study material "(.+)"$/ do|search_text|
  step 'I fill in "search_term" with "'+search_text+'"'
  step 'I press "GO"'
end

When /^I should see search results for "(.+)"$/ do|search_text|
  step 'I should see "'+search_text+'" within result box'
end

When /^I should be able to sort search and filter results$/ do
  #sort order Alphabetical
  step 'I fill in "search_term" with "lines"'
  step 'I press "GO"'
  step 'I should wait 2 seconds'
  find(:xpath, "//label[@for = 'sort_order_name_ASC']").click
  step 'I should wait 2 seconds'
  step '"graphs and lines" should appear before "intersecting lines"'
  step '"intersecting lines" should appear before "parallel lines"'
  
  created_at = Date.today
  ['intersecting lines', 'parallel lines', 'graphs and lines'].each do |activity|
    act = Activity.find_by_name(activity)
    created_at = created_at - 1
    act.created_at = created_at
    act.updated_at = created_at
    act.save!
  end
  
  #sort order oldest
  find(:xpath, "//label[@for = 'sort_order_created_at_ASC']").click
  step 'I should wait 2 seconds'
  step '"graphs and lines" should appear before "parallel lines"'
  step '"parallel lines" should appear before "intersecting lines"'
  
  #sort order newest
  find(:xpath, "//label[@for = 'sort_order_created_at_DESC']").click
  step 'I should wait 2 seconds'
  step '"intersecting lines" should appear before "parallel lines"'
  step '"parallel lines" should appear before "graphs and lines"'
  
  #assign activity to class
  step 'the Activity "intersecting lines" is assigned to the class "Physics"'
  step 'the Activity "intersecting lines" is assigned to the class "Geography"'
  step 'the Activity "intersecting lines" is assigned to the class "Mathematics"'
  step 'the Activity "parallel lines" is assigned to the class "Mathematics"'
  step 'the Activity "parallel lines" is assigned to the class "Geography"'
  
  #sort order by popularity
  find(:xpath, "//label[@for = 'sort_order_offerings_count_DESC']").click
  step 'I should wait 2 seconds'
  step '"intersecting lines" should appear before "parallel lines"'
  step '"parallel lines" should appear before "graphs and lines"'
  
  
end