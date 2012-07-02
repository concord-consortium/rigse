
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
  login_as(username, password)
end

When /^I log out$/ do
  visit "/logout"
end

Given /^I am an anonymous user$/ do
  User.anonymous(true)
  visit('/logout')
  URI.parse(current_url).path.should == '/'
end


Given /^the following vendor interfaces exist:$/ do |interfaces_table|
  # table is a Cucumber::Ast::Table
  interfaces_table.hashes.each do |hash|
    Factory(:probe_vendor_interface, hash)
  end
end

Then /^I should see the following form checkboxes:$/ do |checkbox_table|
  checkbox_table.hashes.each do |hash|
    field = find_field(hash[:name])
    if hash[:checked] =~ /true/
      field.should be_checked
    else
      field.should_not be_checked
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
  within_fieldset("Probeware Interface") do
    selection_table.hashes.each do |hash|
      if defined?(RSpec::Rails::Matchers)
        page.should have_content(hash[:option])
      else
        assert page.has_content?(hash[:option])
      end
    end
  end
end

Then /^I should not see the following selection options:$/ do |selection_table|
  within_fieldset("Probeware Interface") do
    selection_table.hashes.each do |hash|
      if defined?(RSpec::Rails::Matchers)
        page.should_not have_content(hash[:option])
      else
        assert(! page.has_content?(hash[:option]))
      end
    end
  end
end

