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


And /^(?:|I )open the "Assign to a class" popup for the (investigation|activity) "(.+)"$/ do |material_type, material_name|
  material_id = nil
  case material_type
    when "investigation"
      material_id = Investigation.find_by_name(material_name).id
    when "activity"
      material_id = Activity.find_by_name(material_name).id
  end
  
  within(:xpath,"//div[@id = 'search_#{material_type}_#{material_id}']") do
    step 'I follow "Assign to a Class"'
  end
end