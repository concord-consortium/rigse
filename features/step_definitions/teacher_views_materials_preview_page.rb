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

When /^(?:|I )should be able to share (investigation|activity) "(.+)"$/ do |material, material_name|
    case material
      when "investigation"
        material_id = Investigation.find_by_name(material_name).id
        element = page.find(:xpath, "//div[@id='Inv#{material_id}Share']/div[@class='ss-fb sharelink']")
        element.should be_visible
        element = page.find(:xpath, "//div[@id='Inv#{material_id}Share']/div[@class='ss-tw sharelink']")
        element.should be_visible
        element = page.find(:xpath, "//div[@id='Inv#{material_id}Share']/div[@class='ss-li sharelink']")
        element.should be_visible
        element = page.find(:xpath, "//div[@id='Inv#{material_id}Share']/div[@class='ss-po sharelink']")
        element.should be_visible
      when "activity"
        material_id = Activity.find_by_name(material_name).id
        element = page.find(:xpath, "//div[@id='Act#{material_id}Share']/div[@class='ss-fb sharelink']")
        element.should be_visible
        element = page.find(:xpath, "//div[@id='Act#{material_id}Share']/div[@class='ss-tw sharelink']")
        element.should be_visible
        element = page.find(:xpath, "//div[@id='Act#{material_id}Share']/div[@class='ss-li sharelink']")
        element.should be_visible
        element = page.find(:xpath, "//div[@id='Act#{material_id}Share']/div[@class='ss-po sharelink']")
        element.should be_visible
    end
end
