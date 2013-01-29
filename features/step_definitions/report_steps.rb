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

When /^(?:|I )apply filter for the question "(.*)" in the report page$/ do |question|
  step 'I wait 2 seconds'
  page.driver.browser.switch_to.window page.driver.browser.window_handles.last do
    within(:xpath,"//div[@class='report_embeddable' and contains(.,'#{question}')]") do
      check('filter[Embeddable::MultipleChoice][]')
    end
  step 'I press "Show selected"'
  end
end

Then /^(?:|I )should see question "(.*)" checked when all question is displayed in the report page$/ do |question|
  step 'I wait 2 seconds'
  page.driver.browser.switch_to.window page.driver.browser.window_handles.last do
    step 'I press "Show all"'
    within(:xpath,"//div[@class='report_embeddable' and contains(.,'#{question}')]") do
      has_checked_field?('filter[Embeddable::MultipleChoice][]')
    end
  end
end

Then /^(?:|I )click "(.*)" button on report page$/ do |button_name|
  step 'I wait 2 seconds'
  page.driver.browser.switch_to.window page.driver.browser.window_handles.last do
    step_text = "I press \"#{button_name}\""
    step step_text
  end
end

Then /^(?:|I )should see "(.+)" message on the report page$/ do |message_text|
  page.driver.browser.switch_to.window page.driver.browser.window_handles.last do
    step_text = "I should see \"#{message_text}\" within the lightbox in focus"
    step step_text
  end
end
