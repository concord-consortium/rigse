def find_or_create_offering(runnable,clazz,type="Investigation")
    create_hash = {:runnable_id => runnable.id, :runnable_type => type, :clazz_id => clazz.id}
    offering = Portal::Offering.find(:first, :conditions=> create_hash)
    unless offering
      offering = Portal::Offering.create(create_hash)
      offering.save
    end
    offering
end

def login_as(username, password)
  visit "/login"
  within("#project-signin") do
    fill_in("login", :with => username)
    fill_in("password", :with => password)
    click_button("Login")
    @cuke_current_username = username
    #click_button("Submit")
  end
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
  login_as(admin.login, 'password')
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

When /^I debug$/ do
  debugger
  0
end

When /^I wait "(.*)" seconds$/ do |seconds|
  sleep(seconds.to_i)
end

Then /^I should not see the xpath "([^"]*)"$/ do |xpath|
  page.should have_no_xpath xpath
end

Then /^the location should be "([^"]*)"$/ do |location|
  current_url.should == location
end
