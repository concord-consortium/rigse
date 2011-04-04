
Given /the current project is using the following interfaces:/ do |interfaces_table|
  interfaces = interfaces_table.hashes.map { |interf| Probe::VendorInterface.find_by_name(interf[:name])}
  Admin::Project.default_project.enabled_vendor_interfaces = interfaces
  Admin::Project.default_project.save
end

Then /the current project should be using the following interfaces:/ do |interfaces_table|
  interfaces_table.hashes.each do |hash|
    Admin::Project.default_project.enabled_vendor_interfaces.should include(Probe::VendorInterface.find_by_name(hash[:name]))
  end
end

Given /login with username[\s=:,]*(\S+)\s+[(?and),\s]*password[\s=:,]+(\S+)\s*$/ do |username,password|
  visit "/login"
  within("#project-signin") do
    fill_in("login", :with => username)
    fill_in("password", :with => password)
    click_button("Login")
    @cuke_current_username = username
    #click_button("Submit")
  end
end

When /^I log out$/ do
  visit "/logout"
end

Given /^I am an anonymous user$/ do
  User.anonymous(true)
  get '/sessions/destroy'
  response.should redirect_to('/')
  follow_redirect!
  true #  for now ...
end


Given /^the following vendor interfaces exist:$/ do |interfaces_table|
  # table is a Cucumber::Ast::Table
  interfaces_table.hashes.each do |hash|
    Factory(:probe_vendor_interface, hash)
  end
end

Then /^I should see the following form checkboxes:$/ do |checkbox_table|
  checkbox_table.hashes.each do |hash|
    if hash[:checked] =~ /true/
      field_checked = find_field(hash[:name])['checked']
      field_checked.should == "true"
    else
      Then "the \"#{hash[:name]}\" checkbox should not be checked"
    end
  end
end


When /^I check in the following:$/ do |checkbox_table|
  checkbox_table.hashes.each do |hash|
    if hash[:checked] =~ /true/
      check(hash[:name])
    else
      uncheck(hash[:name])
    end
  end
end

When /^(?:|I )should have the following selection options:$/ do |selection_table|
  within_fieldset("Selected Probeware Interface") do
    selection_table.hashes.each do |hash|
      if defined?(Spec::Rails::Matchers)
        page.should have_content(hash[:option])
      else
        assert page.has_content?(hash[:option])
      end
    end
  end
end

Then /^I should not see the following selection options:$/ do |selection_table|
  within_fieldset("Selected Probeware Interface") do
    selection_table.hashes.each do |hash|
      if defined?(Spec::Rails::Matchers)
        page.should_not have_content(hash[:option])
      else
        assert(! page.has_content?(hash[:option]))
      end
    end
  end
end

