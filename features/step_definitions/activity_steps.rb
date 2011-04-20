Given /^the following activities exist:$/ do |table|
  table.hashes.each do |hash|
    user_name = hash.delete('user')
    user = User.find_by_login user_name

    hash['user'] = user
    Factory :activity, hash
  end
end

Given /^the following templated activities exist:$/ do |table|
  ItsiImporter.find_or_create_itsi_activity_template
  table.hashes.each do |hash|
    user_name = hash.delete('user')
    user = User.find_by_login user_name

    template = Activity.templates.first
    activity = template.copy(user)
    activity.update_attributes(hash)
    activity.is_template = false
    activity.save
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

When /^I follow "([^"]*)" for the first multiple choice option$/ do |link|
  with_scope("span.small_left_menu") do
    click_link("delete")
  end
end

When /^I edit the first section$/ do
  # need to use javascript here to make them visible so selenium will allow clicking on them
  page.execute_script("$$('.template_container').each(function(item) { item.down('.buttons').show()})")
  find(".template_container .template_container .template_enable_button").click
  find(".template_container .template_container .template_edit_button").click
end

When /^I fill in the first templated activity section with "([^"]*)"$/ do |value|
  page.execute_script("tinyMCE.editors[0].setContent('#{value}')")
end