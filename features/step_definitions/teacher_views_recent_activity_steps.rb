Then /^I should see the progress of the student$/ do
  page.should have_xpath("//table/tbody/tr[@class='legend_row']")
  not_started = page.has_xpath?("//table/tbody/tr/td[@class='RightMost_legend_not_started']")
  in_progress =  page.has_xpath?("//table/tbody/tr/td[@class='Middle_legend_progress']")
  complete =  page.has_xpath?("//table/tbody/tr/td[@class='LeftMost_legend_completed']")

  if(!complete and in_progress and !not_started)
    page.should have_xpath("//table/tbody/tr/td[@class='Middle_legend_progress']")
    page.should_not have_xpath("//table/tbody/tr/td[@class='LeftMost_legend_completed']")
    page.should_not have_xpath("//table/tbody/tr/td[@class='RightMost_legend_not_started']")  
  elsif(!complete and in_progress and not_started)
    page.should have_xpath("//table/tbody/tr/td[@class='Middle_legend_progress']")
    page.should_not have_xpath("//table/tbody/tr/td[@class='LeftMost_legend_completed']")
    page.should have_xpath("//table/tbody/tr/td[@class='RightMost_legend_not_started']")
  elsif(complete and !in_progress and !not_started)
    page.should_not have_xpath("//table/tbody/tr/td[@class='Middle_legend_progress']")
    page.should have_xpath("//table/tbody/tr/td[@class='LeftMost_legend_completed']")
    page.should_not have_xpath("//table/tbody/tr/td[@class='RightMost_legend_not_started']")  
  elsif(complete and !in_progress and not_started)
    page.should_not have_xpath("//table/tbody/tr/td[@class='Middle_legend_progress']")
    page.should have_xpath("//table/tbody/tr/td[@class='LeftMost_legend_completed']")
    page.should have_xpath("//table/tbody/tr/td[@class='RightMost_legend_not_started']")  
  elsif(complete and in_progress and !not_started)
    page.should have_xpath("//table/tbody/tr/td[@class='Middle_legend_progress']")
    page.should have_xpath("//table/tbody/tr/td[@class='LeftMost_legend_completed']")
    page.should_not have_xpath("//table/tbody/tr/td[@class='RightMost_legend_not_started']")
  end
 click_link('Show detail')
 page.should have_xpath("//div[@class='progressbar_container']/div[@class='progressbar']/div[@class='progress']") 
end

When /^(?:I )should see "(.*)" in In-progress on the recent activity page$/ do |student_name|
  step_text = "I should see the xpath \"//tr/td/div[contains(.,'#{student_name}')]\""
  step step_text
end