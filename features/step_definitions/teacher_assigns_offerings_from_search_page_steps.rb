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

Then /^(?:|I )follow assign to a class link for investigation "(.+)"$/ do |investigation_name|

  within(:xpath,"//div[@class='material_list_item' and contains(., '#{investigation_name}')]") do
    step 'I follow "Assign to a Class"'
  end
end

Then /^(?:|I )follow assign to a class link for activity "(.+)"$/ do |activity_name|

  within(:xpath,"//div[@class='material_list_item' and contains(., '#{activity_name}')]") do
    step 'I follow "Assign to a Class"'
  end
end

And /^(?:|I )follow assing to a class link for investigation "(.+)"$/ do|investigation_name|
  investigation_id = Investigation.find_by_name('#{investigation_name}').id
  within(:xpath,"//div[@id = 'search_investigation_#{investigation_id}']") do
    step 'I follow "Assign to a Class"'
  end
end

And /^(?:|I )follow assing to a class link for activity "(.+)"$/ do|activity_name|

  activity_id = Activity.find_by_name('#{activity_name}').id
  within(:xpath,"//div[@id = 'search_activity_#{activity_id}']") do
    step 'I follow "Assign to a Class"'
  end
end
