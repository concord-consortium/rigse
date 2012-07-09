Given /^grade levels for classes is enabled$/ do
  project = Admin::Project.default_project
  project.enable_grade_levels = true
  project.save
end

Given /^member registration is (.+)$/ do |member_registration|
  project = Admin::Project.default_project
  state = case member_registration
  when 'enabled' then true
  when 'disabled' then false
  else Raise "member registration must be 'enabled' or 'disabled' in features"
  end
  project.enable_member_registration = state
  project.save
end

When /^an admin sets the jnlp CDN hostname to "([^"]*)"$/ do |cdn_hostname|
  admin = Factory.next(:admin_user)
  login_as(admin.login)
  visit admin_projects_path
  click_link "edit project"
  fill_in "admin_project[jnlp_cdn_hostname]", :with => cdn_hostname
  # we turn on the opportunisitc installer inorder to test the most functionality
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

When /^I create a new project with the description "([^"]*)"$/ do |description|
  click_link "create Project"
  fill_in "admin_project[description]", :with => description
  click_button "Save"
  page.should have_no_button("Save")
end

