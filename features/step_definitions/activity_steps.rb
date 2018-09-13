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
    activity = Activity.where(name: hash['activity']).first_or_create(:description => hash['activity'])
    activity.user = FactoryGirl.create(:user)
    expect(activity.save).to be_truthy
    section = Section.where(name: hash['section']).first_or_create
    page = Page.where(name: hash['page']).first_or_create
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

When /^(?:|I )create activities "(.+)" before "(.+)" by date$/ do |activities_name1, activities_name2|
  created_at = Date.today
  ['activities_name1', 'activities_name2'].each do |activity|
    act = Activity.where(name: activity).first_or_create
    created_at = created_at - 1
    act.created_at = created_at
    act.updated_at = created_at
    act.save!
  end
end

#Table: | investigation | activity | activity_teacher_only | section   | page   | multiple_choices |
Given /^a simple activity with a multiple choice exists$/ do
  activity = Activity.create(:name => 'simple activity', :description => 'simple activity')
  activity.user = FactoryGirl.create(:user)
  expect(activity.save).to be_truthy

  section = Section.create(:name => 'simple section')
  activity.sections << section

  page = Page.create(:name => 'simple page')
  section.pages << page

  mc = FactoryGirl.create(:multiple_choice)
  mc.addChoice("Choice 1")
  mc.addChoice("Choice 2")
  mc.pages << page
end
