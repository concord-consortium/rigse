Given /^the following activities exist:$/ do |table|
  table.hashes.each do |hash|
    user_name = hash.delete('user')
    user = User.find_by_login user_name

    hash['user'] = user
    Factory :activity, hash
  end
end

Given /^the following templated activities exist:$/ do |table|
  ItsiImporter.find_or_create_itsi_activity_template
  table.hashes.each do |hash|
    user_name = hash.delete('user')
    user = User.find_by_login user_name

    template = Activity.templates.first
    activity = template.copy(user)
    activity.update_attributes(hash)
    activity.is_template = false
    activity.save
  end
end
When /^I follow "([^"]*)" for the first multiple choice option$/ do |link|
  with_scope("span.small_left_menu") do
    click_link("delete")
  end
end

#Table: | activity | section   | page   | multiple_choices |
Given /^the following activities with multiple choices exist:$/ do |activity_table|
  activity_table.hashes.each do |hash|
    activity = Activity.find_or_create_by_name(hash['activity'], :description => hash['activity'])
    activity.user = Factory(:user)
    activity.save.should be_true
    section = Section.find_or_create_by_name(hash['section'])
    page = Page.find_or_create_by_name(hash['page'])
    mcs = hash['multiple_choices'].split(",").map{ |q| Embeddable::MultipleChoice.find_by_prompt(q.strip) }
    mcs.each do |q|
      q.pages << page
    end
    imgqs = hash['image_questions'].split(",").map{ |q| Embeddable::ImageQuestion.find_by_prompt(q.strip) }
    imgqs.each do |q|
      q.pages << page
    end
    page.save
    section.pages << page
    activity.sections << section
  end
end

When /^I edit the first section$/ do
  # all sections are currently enabled at start. If we make them disabled by default, we need to
  # uncomment the following line:
  # find(".template_container .template_enable_check").click    
  
  # when sections start out blank, there won't be any edit link showing, and this
  # will fail. At that time, we can simply skip clicking on an edit link
  find(".template_container .template_container .template_edit_link").click
end

When /^I fill in the first templated activity section with "([^"]*)"$/ do |value|
  page.execute_script("tinyMCE.editors[0].setContent('#{value}')")
end
