Given /^the following activities exist:$/ do |table|
  table.hashes.each do |hash|
    user_name = hash.delete('user')
    user = User.find_by_login user_name

    hash['user'] = user
    Factory :activity, hash
  end
end

When /^I assign the activity "([^"]*)" to the class "([^"]*)"$/ do |activity_name, class_name|
  clazz = Portal::Clazz.find_by_name(class_name)
  activity = Activity.find_by_name(activity_name)
  Factory.create(:portal_offering, {
    :runnable => activity,
    :clazz => clazz
  })
end
