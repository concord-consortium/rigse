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