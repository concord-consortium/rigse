
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
  fill_in("login", :with => username)
  fill_in("password", :with => password)
  click_button("Login")
end

When /^I log out$/ do
  visit "/logout"
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
      Then "the \"#{hash[:name]}\" checkbox should be checked"
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
  with_scope("select") do
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
  with_scope("select") do
    selection_table.hashes.each do |hash|
      if defined?(Spec::Rails::Matchers)
        page.should_not have_content(hash[:option])
      else
        assert(! page.has_content?(hash[:option]))
      end
    end
  end
end

