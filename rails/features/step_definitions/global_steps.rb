def find_or_create_offering(runnable,clazz)
    type = runnable.class.to_s
    create_hash = {:runnable_id => runnable.id, :runnable_type => type, :clazz_id => clazz.id}
    offering = Portal::Offering.where(create_hash).first
    unless offering
      offering = Portal::Offering.create(create_hash)
      offering.save
    end
    offering
end

def login_as(username)
  visit "/login/#{username}"
  expect(page).to have_content(username)
  @cuke_current_username = username
end

def login_with_ui_as(username, password)

  visit "/users/sign_in"

  within(find(:xpath, "//form[@id='new_user']")) do
    fill_in("user_login",       :with => username)
    fill_in("user_password",    :with => password)
    click_button("Sign in")
    @cuke_current_username = username
  end

  user = User.find_by_login(username)
  user_first_name = user.first_name
  user_last_name = user.last_name
  expect(page).to have_content("Welcome")
  expect(page).to have_content(user_first_name)
  expect(page).to have_content(user_last_name)
end

def post_with_bearer_token(path, post_data, user = 'admin')
  if Client.count == 0
    Client.create(
      :name => "test_api_client",
      :app_id => "test_api_client",
      :app_secret => SecureRandom.uuid,
      :domain_matchers => ""
    )
  end
  user = User.find_by_login('admin')
  grant = user.access_grants.create({
                                      :client => Client.last,
                                      :state => nil,
                                      :access_token_expires_at => Time.now + 10.minutes
                                    }, :without_protection => true)
  token = grant.access_token
  page.driver.post(path, post_data, {"Authorization" => "Bearer #{token}"})
end

def login_with_auth_login_page_as(username, password)
  visit "/auth/login"
  fill_in("username", :with => username)
  fill_in("password", :with => password)
  click_button("Log In")
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

Given /the following users exist:$/i do |users_table|
  users_table.hashes.each do |hash|
    roles = hash.delete('roles')
    if roles
      roles = roles ? roles.split(/,\s*/) : nil
    else
      roles =  []
    end
    begin
      user = FactoryBot.create(:user, hash)
      roles.each do |role|
        user.add_role(role)
      end
      user.save!
      user.confirm!

    rescue ActiveRecord::RecordInvalid
      # assume this user is already created...
    end
  end
end

Given /^(?:|I )login as an admin$/ do
  login_as('admin')
end

Given /^I am an anonymous user$/ do
  visit('/users/sign_out')
  expect(['/home', '/']).to include URI.parse(current_url).path
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

Given /I login with username[\s=:,]*(\S+)\s+[\s]*password[\s=:,]+(\S+)\s*$/ do |username, password|
  step 'I log out'
  login_with_ui_as(username, password)
end

Given /I login with username[\s=:,]*(\S+)\s+[[and]?,\s]*password[\s=:,]+(\S+)\s* using auth\/login page$/ do |username, password|
  step 'I log out'
  login_with_auth_login_page_as(username, password)
end

When /^I log out$/ do
  visit "/users/sign_out"
  expect(['/home', '/']).to include URI.parse(current_url).path
end

Given /^there are (\d+) (.+)$/ do |number, model_name|
  model_name = model_name.gsub(/\s/, '_').singularize
  the_class = model_name.classify.constantize

  the_class.destroy_all
  number.to_i.times do |i|
    FactoryBot.create(model_name.to_sym)
  end
end

# Then the investigation named "Test" should have "offerings_count" equal to "1"
Then /^the (.*) named "([^"]*)" should have "([^"]*)" equal to "([^"]*)"$/ do |class_name, obj_name, field, value|
  obj = class_name.gsub(/\s/, "_").classify.constantize.find_by_name(obj_name)
  expect(obj.send(field.to_sym).to_s).to eq(value)
end

Then /^"(.*)" should appear before "(.*)"$/ do |first_item, second_item|
  # these first two lines make sure the content is actually on the page
  # and will trigger synchronized waiting
  expect(page).to have_content(first_item)
  expect(page).to have_content(second_item)
  # this won't trigger synchronized waiting so if there is synchronization issues you should
  # try to verify something is on the page, before using this step
  expect(page.body).to match(/#{first_item}.*#{second_item}/m)
end


Then /^I should see the sites name$/ do
  site_name = APP_CONFIG[:site_name]
  expect(page.title).to eq(site_name)
end

When /^(?:|I )debug$/ do
  binding.pry
  # this 0 is here so the debugger stop in a nice place instead of cucumber code
  0
end

When /^I wait (?:for )?(\d+) second(?:s)?$/ do |seconds|
  sleep(seconds.to_i)
end

Then /^I should wait (?:for )?(\d+) second(?:s)?/ do |seconds|
  sleep(seconds.to_i)
end

Then /^I should not see the xpath "([^"]*)"$/ do |xpath|
  expect(page).to have_no_xpath xpath
end

Then /^I should see the xpath "([^"]*)"$/ do |xpath|
  expect(page).to have_xpath xpath
end

Then /^the location should be "([^"]*)"$/ do |location|
  expect(current_url).to eq(location)
end

Then /^I should see the button "([^"]*)"$/ do |locator|
  find(:xpath, XPath::HTML.button(locator))
end

Then /^I should not see the button "([^"]*)"$/ do |button|
  expect(page).to have_no_button(button)
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
  expect(dialog_text).to eq(text)
  page.driver.browser.switch_to.alert.accept
end

When /^the newly opened window (should|should not) have content "(.*)"$/ do |present, content|
  step 'I wait 2 seconds'
  page.driver.browser.switch_to.window page.driver.browser.window_handles.last do
    case present
      when "should"
      expect(page).to have_content(content)
      when "should not"
      expect(page).to have_no_content(content)
    end
  end
end

When /^Help link should not appear in the top navigation bar$/ do
  expect(find('#help-link')).not_to be_visible
end

When /^(?:|I )close the newly opened window$/ do
  page.driver.browser.switch_to.window page.driver.browser.window_handles.last do
    page.execute_script "window.close();"
  end
end

require 'securerandom'
When /^I take a screenshot(?: as "([^"]*)")?/ do |file|
  file = "tmp/#{SecureRandom.hex(4)}.png" unless file
  page.driver.browser.save_screenshot file
  puts "snapshot taken: #{file}"
end
