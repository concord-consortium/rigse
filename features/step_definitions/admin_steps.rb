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

When /^an admin sets the jnlp CDN hostname to "([^"]*)"$/ do |cdn_hostname|
  admin = User.find_by_login('admin')
  login_as(admin.login)
  visit admin_settings_path
  click_link "edit settings"
  fill_in "admin_settings[jnlp_cdn_hostname]", :with => cdn_hostname
  # we turn on the opportunistic installer in order to test the most functionality
  check "Use JavaClientLauncher"
  click_button "Save"
  page.should have_no_button("Save")
end

Then /^the installer jnlp should have the CDN hostname "([^"]*)" in the right places$/ do |hostname|
  inv = Factory.create(:investigation)
  # switch the driver to rack_test so we can inspect the content
  original_driver = Capybara.current_driver
  Capybara.current_driver = :rack_test
  # request some simple jnlp perhaps we need to actually make an investigation to request before we can do this
  visit "/investigations/#{inv.id}.jnlp"
  jnlp_xml = Nokogiri::XML(page.driver.response.body)
  codebase = jnlp_xml.xpath("/jnlp/@codebase")
  codebase.text.should match %r{^http://#{hostname}.*}

  wrapped_jnlp_attr = jnlp_xml.xpath("/jnlp/resources/property[@name='wrapped_jnlp']/@value")
  wrapped_jnlp_attr.should_not be_nil
  wrapped_jnlp_attr.text.should_not match %r{^http://#{hostname}.*}

  mirror_host_attr = jnlp_xml.xpath("/jnlp/resources/property[@name='jnlp2shell.mirror_host']/@value")
  mirror_host_attr.should_not be_nil
  mirror_host_attr.text.should == hostname

  Capybara.current_driver = original_driver
end

Then /^the non installer jnlp codebase should not start with "([^"]*)"$/ do |codebase_start|
  inv = Factory.create(:investigation)
  # switch the driver to rack_test so we can inspect the content
  original_driver = Capybara.current_driver
  Capybara.current_driver = :rack_test

  visit "/investigations/#{inv.id}.jnlp?skip_installer=true"
  jnlp_xml = Nokogiri::XML(page.driver.response.body)

  # make sure we really are not using the installer
  main_class_attr = jnlp_xml.xpath("/jnlp/application-desc/@main-class")
  main_class_attr.should_not be_nil
  main_class_attr.text.should == 'net.sf.sail.emf.launch.EMFLauncher2'

  codebase = jnlp_xml.xpath("/jnlp/@codebase")
  codebase.text.should_not match /^#{codebase_start}.*/


  Capybara.current_driver = original_driver
end

When /^I create new settings with the description "([^"]*)"$/ do |description|
  click_link "create Settings"
  fill_in "admin_settings[description]", :with => description
  click_button "Save"
  page.should have_no_button("Save")
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
  page.should have_no_button("Save")
end 
