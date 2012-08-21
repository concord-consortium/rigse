
When /add a multiple choice question$/ do
  # pending # express the regexp above with the code you wish you had
end

When /^(?:|I )follow xpath "([^\"]*)"$/ do |xpath|
  node = find(:xpath, xpath)
  node.click
end

When /show the first section of the "(.*)" investigation$/ do |investigation_name|
  investigation = Investigation.find_by_name(investigation_name)
  section = investigation.sections.first
  visit section_path(section)
end

When /^I save the investigation$/ do
  # ideally we would find the <input type="submit"> inside the form "new_investigation"
  # but it isn't clear how to do that
  scroll_into_view("#new_investigation")
  click_button("Save")
end

Given /a mock gse/ do
  domain = mock_model(RiGse::Domain,
    :id => 1,
    :name => "physics"
  )
  gse = mock_model(RiGse::GradeSpanExpectation,
    :domain => domain,
    :id => 1,
    :grade_span => '9-11',
    :print_summary_data => "summary data",
    :gse_key => 'PHY-9-11',
    :expectations => [] # not very ambitious
  )
  domain.stub(:grade_span_expectations).and_return([gse])

  RiGse::GradeSpanExpectation.stub!(:default).and_return(gse)
  RiGse::Domain.stub!(:find).and_return([domain])
  RiGse::Domain.stub!(:find).with(1).and_return(domain)
end


#Table: | prompt | answers | correct_answer |
Given /^the following multiple choice questions exists:$/ do |mult_table|
  mult_table.hashes.each do |hash|
    prompt = hash['prompt']
    choices = hash['answers'].split(",")
    choices.map!{|c| c.strip}
    correct = hash['correct_answer']
    multi = Embeddable::MultipleChoice.find_or_create_by_prompt(prompt)
    choices.map! { |c| Embeddable::MultipleChoiceChoice.create(
      :choice => c, 
      :multiple_choice => multi, 
      :is_correct => (c == correct)
    )}
    multi.choices = choices
  end
end

Given /^there is an image question with the prompt "([^"]*)"$/ do |prompt|
  image_question = Embeddable::ImageQuestion.find_or_create_by_prompt(prompt)
end

Given /^I created a data collector$/ do
  Embeddable::DataCollector.create(:user_id => User.find_by_login(@cuke_current_username).id)
end

When /^I add a "([^"]*)" to the page$/ do |embeddable|
  # this requires a javascript enabled driver
  # this simulates roughly what happens when the mouse is moved over the plus icon

  # this first part is what happens in the onmouseover event on the plus icon
  # it is necessary to call first because it positions the menu relative to the plus icon
  # it also adds listeners to make the menu show up, but we aren't using them since we 
  # aren't really moving the mouse.
  page.execute_script("dropdown_for('button_add_menu','add_menu')")

  # now that the menu is positioned we can just manually show it
  page.execute_script("$('add_menu').show()")
  click_link(embeddable)
  page.execute_script("$('add_menu').hide()")
end

When /^I copy the embeddable "([^"]*)"(?: by clicking on the (title|content))$/ do |embeddable, click_point|
  # select the embeddable
  elem = case click_point
  when "title"
    find(:xpath, %!//span[@class="component_title" and contains(., "#{embeddable}")]!)
  else
    find(:xpath, %!//span[@class="component_title" and contains(., "#{embeddable}")]/../../..//div[@class="item item_selectable "]!)
  end
  elem.click

  show_actions_menu
  click_link("copy Text: content goes here ...")
  page.driver.browser.switch_to.alert.dismiss
  page.execute_script("$('actions_menu').hide()")
end

When /^I paste the embeddable "([^"]*)"$/ do |embeddable|
  show_actions_menu
  click_link("paste Text: content goes here ...")
  page.execute_script("$('actions_menu').hide()")
end


