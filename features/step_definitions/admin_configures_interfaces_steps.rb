
Given /the following users[(?exist):\s]*$/i do |users_tabe|
  users_tabe.hashes.each do |hash|
    roles = hash.delete('roles')
    roles = roles ? roles.split(/,\s*/) : nil
    user = Factory(:user, hash)
    roles.each do |role|
      user.add_role(role)
    end
    user.register
    user.activate
    user.save!
  end
end

Given /login with username[\s=:,]*(\S+)\s+[(?and),\s]*password[\s=:,]+(\S+)\s*$/ do |username,password|
  visit "/login"
  fill_in("login", :with => username)
  fill_in("password", :with => password)
  click_button("Login")
end

Given /^the following vendor interfaces exist:$/ do |interfaces_table|
  # table is a Cucumber::Ast::Table
  interfaces_table.hashes.each do |hash|
    Factory(:probe_vendor_interface, hash)
  end
end

Then /^I should see the following form checkboxes:$/ do |checkbox_table|
  pending "WIP:  noah can't get this test to pass!"
  # table is a Cucumber::Ast::Table
  checkbox_table.hashes.each do |hash|
    field = find_field(hash['name'].gsub(/\s+/,"_"))
    field.should_not be nil
    checked = field['checked']
    if hash['checked'] =~ /true/
      if defined?(Spec::Rails::Matchers)
        checked.should == 'checked'
      else
        assert_equal 'checked', checked
      end
    else
      if defined?(Spec::Rails::Matchers)
        checked.should_not == 'checked'
      else
        assert_not_equal 'checked', checked
      end
    end
  end
end
