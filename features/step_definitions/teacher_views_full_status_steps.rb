When /^(?:I )expand the column "(.*)" on the Full Status page$/ do |offering_name|
  step_text = "follow xpath \"//th[div[contains(.,'#{offering_name}')]]\""
  step step_text
end

When /^the column for "(.*)" on the Full Status page should be (expanded|collapsed)$/ do |column_name, expanded_or_collapsed|
  xpath_expression = "//th[@title='#{column_name}' and contains(., '#{column_name}')]"
  element = page.find(:xpath, xpath_expression)
  if expanded_or_collapsed == 'expanded'
    expect(element).to be_visible
  else
    expect(element).not_to be_visible
  end
end