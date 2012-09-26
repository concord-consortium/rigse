When /^Report page (should|should not) have student name "(.*)" in answered section for the question "(.*)"$/ do |present, student_name, question|
  step 'I wait 2 seconds'
  page.driver.browser.switch_to.window page.driver.browser.window_handles.last do
    find(:xpath,"//div[@class='accordion_container' and contains(., '#{question}')]/div[@class[contains(., 'accordion_toggle_closed')]]").click
    
    case present
      when "should" 
      page.should have_content(student_name)
      when "should not"
      page.should have_no_content(student_name)
    end
  end
end

When /^Report page (should|should not) have content "(.*)"$/ do |present, content|
  step 'I wait 2 seconds'
  page.driver.browser.switch_to.window page.driver.browser.window_handles.last do
    case present
      when "should"
      page.should have_content(content)
      when "should not"
      page.should have_no_content(content)
    end
  end
end