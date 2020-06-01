
When /^(?:|I )create a notice "(.*)"$/ do|notice_html, selected_roles|
  visit(path_to("the admin create notice page"))
  step "I fill \"#{notice_html}\" in the tinyMCE editor with id \"notice_html\""
  step('I press "Publish Notice"')
  step "I should see \"#{notice_html}\""
end

And /^(?:|I )create the following notices:$/ do |table|
  table.hashes.each do |hash|
    step "I create a notice \"#{hash[:notice_html]}\"\""
  end
end

Given /^a notice "(.*)"/ do |notice_html|
  # use a factory to make a generic notice with this text
  notice = FactoryBot.create(:site_notice, notice_html: notice_html)
end
