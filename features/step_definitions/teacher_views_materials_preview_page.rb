And /^(?:|I )click link "(.+)" for (investigation|activity) "(.+)" on the materials preview page$/ do |link, material_type, material_name|
  case material_type
    when "investigation"
      within(:xpath,"//table[@class = 'browse_material_header']") do
        click_link(link)
      end
    when "activity"
      within(:xpath,"//table[@class = 'activity_list']/tbody/tr[contains(.,'#{material_name}')]") do
        click_link(link)
      end
  end
end

When /^(?:|I )uncheck "(.+)" from the investigation preview page$/ do |activity_name|
  within(:xpath,"//table[@class = 'activity_list']/tbody/tr[contains(.,'#{activity_name}')]") do
    uncheck("activity_id[]")
  end
end

When /^the check box for the activity "(.+)" (should|should not) be checked$/ do |activity_name, checkbox_checked|
  case checkbox_checked
    when "should"
      within(:xpath,"//table[@class = 'activity_list']/tbody/tr[contains(.,'#{activity_name}')]") do
        field_checked = find_field("activity_id[]")['checked']
        field_checked.should be_true
      end
    when "should not"
      within(:xpath,"//table[@class = 'activity_list']/tbody/tr[contains(.,'#{activity_name}')]") do
        field_checked = find_field("activity_id[]")['checked']
        field_checked.should be_false
      end
  end
end

When /^the share popup should have content "(.+)"$/ do |text|
  within_frame('at3winshare-iframe') do
    within(:xpath,"//div[@id = 'main']") do
      page.should have_content(text)
    end
  end
end