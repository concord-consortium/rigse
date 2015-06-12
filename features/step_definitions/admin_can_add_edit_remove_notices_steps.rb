
When /^(?:|I )create a notice "(.*)" for the roles "(.*)"$/ do|notice_html, selected_roles|
  
  visit(path_to("the admin create notice page"))
  step "I fill \"#{notice_html}\" in the tinyMCE editor with id \"notice_html\""
  
  uncheck('Admin')
  uncheck('Manager')
  uncheck('Researcher')
  uncheck('Author')
  uncheck('Member')
  
  unless selected_roles == ''
    selected_roles = selected_roles.split(',')
    selected_roles.each do |selected_role|
      check(selected_role)
    end
  end
  
  step('I press "Publish Notice"')
  
  step "I should see \"#{notice_html}\""
end

And /^(?:|I )create the following notices:$/ do |table|
  table.hashes.each do |hash|
    step "I create a notice \"#{hash[:notice_html]}\" for the roles \"#{hash[:roles]}\""
  end
end

Given /^a notice for all roles "(.*)"/ do |notice_html|
  # use a factory to make a genric notice with this text
  notice = Factory :site_notice, notice_html: notice_html

  [:admin,:member,:researcher,:author,:manager].each do |role_name|
    site_notice_role = Admin::SiteNoticeRole.new
    site_notice_role.admin_site_notice = notice
    site_notice_role.role = Role.find_by_title(role_name.to_s)
    site_notice_role.save!
  end
end

Given /^a notice "(.*)" for roles "(.+)"/ do |notice_html, selected_roles|
  # use a factory to make a genric notice with this text
  notice = Factory :site_notice, notice_html: notice_html

  selected_roles.split(',').each do |role_name|
    site_notice_role = Admin::SiteNoticeRole.new
    site_notice_role.admin_site_notice = notice
    site_notice_role.role = Role.find_by_title(role_name.strip.downcase.to_s)
    site_notice_role.save!
  end
end
