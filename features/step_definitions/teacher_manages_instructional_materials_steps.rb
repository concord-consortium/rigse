
Then /^A report window opens of offering "(.+)"$/ do |offering|
  #offering = Portal::Offering.find_by_name(offering)
  page.driver.browser.switch_to.window page.driver.browser.window_handles.last do
    assert_match(path_to("report of offering \"#{offering}\""), current_url)
  end
end

And /^I click tab number "(.+)"$/ do |tab_number|
  find("div#material_tab_#{tab_number}").click
end

And /^I should see progress bars for the students$/ do
  result = page.execute_script("
    var arrProgressBars = $$('div.progress');
    var bProgressBarWidthIncreased = false;
    var iWidth = null;
    for (var i = 0; i < arrProgressBars.length; i++)
    {
      iWidth = parseInt(arrProgressBars[i].style.width, 10);
      if (iWidth > 0)
      {
        bProgressBarWidthIncreased = true;
      }
    }
    return bProgressBarWidthIncreased;
  ")
  
   raise 'Progress bar fail' if result == false
  
  
end
