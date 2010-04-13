Given /^I am not logged in$/ do
  # pending # express the regexp above with the code you wish you had
  # controller.current_user = User.anonymous
end

Given /^[Ii] am logged in as(\s*the\s*)?[aA]dmin(\s*user\s*)$/ do |x,y|
  visit 'login'
  fill_in('login', :with => 'admin')
  fill_in('password', :with => 'password')
  click_button('Login')
end


Then /^There should be a valid admin user$/ do
  admin = User.find_by_login('admin')
  admin.should_not be_nil
  admin.authenticated?("password").should be true
end

# dont use webrat for these, because of sessions:
When /^I visit the route (.+)$/ do |route|
  get route
end

Then /^I should be redirected (.+)$/ do |named_route|
  response.should redirect_to(named_route)
end
Then /^I should not be redirected (.+)$/ do |named_route|
  response.should_not redirect_to(named_route)
end
