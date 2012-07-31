def find_or_create_offering(runnable,clazz)
    type = runnable.class.to_s
    create_hash = {:runnable_id => runnable.id, :runnable_type => type, :clazz_id => clazz.id}
    offering = Portal::Offering.find(:first, :conditions=> create_hash)
    unless offering
      offering = Portal::Offering.create(create_hash)
      offering.save
    end
    offering
end

def login_as(username)
  visit "/login/#{username}"
  @cuke_current_username = username
end

def login_with_ui_as(username, password)
  visit "/login"
  within("#project-signin") do
    fill_in("login", :with => username)
    fill_in("password", :with => password)
    click_button("Login")
    @cuke_current_username = username
  end
end

# scroll_into_view is a hack so an element is scrolled into view in selenium in IE
# after the following change to selenium is released then scroll_into_view shouldn't be necessary anymore
#  http://code.google.com/p/selenium/source/detail?r=11244
#  http://code.google.com/p/selenium/issues/detail?id=848
# if function is running outside of selenium it is basically a no op
def scroll_into_view(selector)
  el = find(selector)
  # only do this if the native element is a selenium element
  el.native.send_keys(:null) if el.native.class.to_s.split("::").first == "Selenium"
end

Given /the following users[(?exist):\s]*$/i do |users_table|
  User.anonymous(true)
  users_table.hashes.each do |hash|
    roles = hash.delete('roles')
    if roles
      roles = roles ? roles.split(/,\s*/) : nil
    else
      roles =  []
    end
    begin
      user = Factory(:user, hash)
      roles.each do |role|
        user.add_role(role)
      end
      user.register
      user.activate
      user.save!
    rescue ActiveRecord::RecordInvalid
      # assume this user is already created...
    end
  end
end

Given /^(?:|I )login as an admin$/ do
  admin = Factory.next(:admin_user)
  login_as(admin.login)
end


# the quote in the pattern is to prevent this from matching other rules
# and hopefully there is no need for quotes in a usernames
Given /^I am logged in with the username ([^"]*)$/ do |username|
  login_as(username)
end

Given /^(?:|I )login with username[\s=:,]*(\S+)$/ do |username|
  login_as(username)
  visit "/"
end

Given /(?:|I )login with username[\s=:,]*(\S+)\s+[(?and),\s]*password[\s=:,]+(\S+)\s*$/ do |username,password|
  login_with_ui_as(username, password)
end

When /^I log out$/ do
  visit "/logout"
end

Given /^there are (\d+) (.+)$/ do |number, model_name|
  model_name = model_name.gsub(/\s/, '_').singularize
  the_class = model_name.classify.constantize

  the_class.destroy_all
  number.to_i.times do |i|
    Factory.create(model_name.to_sym)
  end
end

# Then the investigation named "Test" should have "offerings_count" equal to "1"
Then /^the (.*) named "([^"]*)" should have "([^"]*)" equal to "([^"]*)"$/ do |class_name, obj_name, field, value|
  obj = class_name.gsub(/\s/, "_").classify.constantize.find_by_name(obj_name)
  obj.send(field.to_sym).to_s.should == value
end

Then /"(.*)" should appear before "(.*)"/ do |first_item, second_item|
  page.body.should =~ /#{first_item}.*#{second_item}/m
end


Then /^I should see the sites name$/ do
  site_name = APP_CONFIG[:site_name]
  if page.respond_to? :should
    page.should have_content(site_name)
  else
    assert page.has_content?(site_name)
  end
end

When /^(?:|I )debug$/ do
  debugger
  # this 0 is here so the debugger stop in a nice place instead of cucumber code
  0
end

When /^I wait (\d+) second[s]?$/ do |seconds|
  sleep(seconds.to_i)
end

Then /^I should not see the xpath "([^"]*)"$/ do |xpath|
  page.should have_no_xpath xpath
end

Then /^I should see the xpath "([^"]*)"$/ do |xpath|
  page.should have_xpath xpath
end

Then /^the location should be "([^"]*)"$/ do |location|
  current_url.should == location
end

Then /^I should see the button "([^"]*)"$/ do |locator| 
  msg = "no button '#{locator}' found"
  find(:xpath, XPath::HTML.button(locator), :message => msg)
end

Then /^I should not see the button "([^"]*)"$/ do |button| 
  page.should have_no_button(button)
end

Then /^(?:|I )should wait ([0-9]+) seconds/ do |seconds|
  sleep(seconds.to_i)
end

Given /^PENDING/ do
  pending
end

When /^(?:|I )accept the dialog$/ do 
  page.driver.browser.switch_to.alert.accept
end

When /^(?:|I )dismiss the dialog$/ do 
  page.driver.browser.switch_to.alert.dismiss
end

Then /^(?:|I )need to confirm "([^"]*)"$/ do |text|
  # currently confirmations like this are done with dialogs
  dialog_text = page.driver.browser.switch_to.alert.text
  dialog_text.should == text
  page.driver.browser.switch_to.alert.accept
end