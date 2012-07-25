
When /^(?:|I )create a notice "(.*)" for the roles "(.*)"$/ do|notice_html, selected_roles|
  
  visit(path_to("the admin create notice page"))
  step "I fill \"#{notice_html}\" in the tinyMCE editor with id \"notice_html\""
  
  uncheck('Admin')
  uncheck('Manager')
  uncheck('Researcher')
  uncheck('Author')
  uncheck('Member')
  
  selected_roles = selected_roles.split(',')
  selected_roles.each do |selected_role|
    check(selected_role)
  end
  
  step('I press "Publish Notice"')
end

And /^(?:|I )create the following notices:$/ do |table|
  table.hashes.each do |hash|
    step "I create a notice \"#{hash[:notice_html]}\" for the roles \"#{hash[:roles]}\""
  end
end