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

Given(/^an admin user named "([^"]*)" with username "([^"]*)" exists$/) do |fullname, username|
  first_name, last_name = fullname.split(' ', 2)
  user = FactoryBot.create(:user, first_name: first_name, last_name: last_name, login: username)
  user.add_role("member")
  user.add_role("admin")
  user.save!
  user.confirm
end

Given(/^a student user named "([^"]*)" exists$/) do |fullname|
  first_name, last_name = fullname.split(' ', 2)
  user = FactoryBot.create(:user, first_name: first_name, last_name: last_name, login: last_name)
  user.add_role("member")
  user.save!
  user.confirm

  portal_student = FactoryBot.create(:full_portal_student, { :user => user })
  portal_student.save!
end

Then /^I switch to "([^"]*)" in the user list by searching "([^"]*)"$/ do |fullname, search|
  visit path_to("user list")
  step 'I should see "Account Report"'
  fill_in("search", :with => search)
  click_button('Search')
  within(:xpath,"//div[@class='action_menu' and contains(.,'#{fullname}')]") do
    click_link('View/Manage')
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
    click_link('View/Manage')
  end
  click_link('Activate')
end

Then /^(?:|I )should see "([^"]*)" in the input box of external URL for help page on settings page$/ do |url|
  step_text = "I should see the xpath \"//input[@name='admin_settings[external_url]' and @value = '#{url}']\""
  step step_text
end

When /^I save the settings$/ do
  click_button "Save"
  expect(page).to have_no_button("Save")
end
