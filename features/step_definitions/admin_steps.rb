Given /^grade levels for classes is enabled$/ do
  settings = Admin::Settings.default_settings
  settings.enable_grade_levels = true
  settings.save
end

Given /^member registration is (.+)$/ do |member_registration|
  settings = Admin::Settings.default_settings
  state = case member_registration
  when 'enabled' then true
  when 'disabled' then false
  else Raise "member registration must be 'enabled' or 'disabled' in features"
  end
  settings.enable_member_registration = state
  settings.save
end

When /^I create new settings with the description "([^"]*)"$/ do |description|
  click_link "create Settings"
  fill_in "admin_settings[description]", :with => description
  click_button "Save"
  expect(page).to have_no_button("Save")
end

Then /^I switch to "([^"]*)" in the user list by searching "([^"]*)"$/ do |fullname, search|
  visit path_to("user list")
  step 'I should see "Account Report"'
  fill_in("search", :with => search)
  click_button('Search')
  within(:xpath,"//div[@class='action_menu' and contains(.,'#{fullname}')]") do
    click_link('Switch')
  end
end

Then /^(?:|I )look for the user by searching "([^"]*)"$/ do |search|
  fill_in("search", :with => search)
  click_button('Search')
end

Then /^(?:|I )activate the user from user list by searching "([^"]*)"$/ do |search|
  fill_in("search", :with => search)
  click_button('Search')
  within(:xpath,"//div[@id='action_menu_wrapper' and contains(.,'#{search}')]") do
    click_link('Activate')
  end
end

Then /^(?:|I )should see "([^"]*)" in the input box of external URL for help page on settings page$/ do |url|
  step_text = "I should see the xpath \"//input[@name='admin_settings[external_url]' and @value = '#{url}']\""
  step step_text
end

When /^I save the settings$/ do
  click_button "Save"
  expect(page).to have_no_button("Save")
end
