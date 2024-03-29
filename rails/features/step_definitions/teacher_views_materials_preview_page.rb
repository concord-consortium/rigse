And /^(?:|I )click link "(.+)" for (investigation|activity) "(.+)" on the materials preview page$/ do |link, material_type, material_name|
  case material_type
    when "investigation"
      within(:xpath,"//div[@class = 'browse_material_data']/div[@class = 'description']") do
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
        expect(field_checked).to be_truthy
      end
    when "should not"
      within(:xpath,"//table[@class = 'activity_list']/tbody/tr[contains(.,'#{activity_name}')]") do
        field_checked = find_field("activity_id[]")['checked']
        expect(field_checked).to be_falsey
      end
  end
end

When(/^I should see the preview button for "(.*?)"$/) do |arg1|
  selector = "a[href*=\".run_resource_html\"]"
  element = page.find(selector)
  expect(element).to be_visible
end
