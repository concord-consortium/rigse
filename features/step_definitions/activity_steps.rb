Given /^the following activities exist:$/ do |table|
  table.hashes.each do |hash|
    user_name = hash.delete('user')
    user = User.find_by_login user_name

    hash['user'] = user
    Factory :activity, hash
  end
end

When /^I follow "([^"]*)" for the first multiple choice option$/ do |link|
  with_scope("span.delete_link") do
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
