Given /^the default project links exist using factories$/ do
  project = FactoryBot.create(:project, name: 'project 1', landing_page_slug: 'project-1')
  FactoryBot.create(:admin_cohort, {
    :project_id => project.id,
    :name => 'project 1 cohort'
  })
  FactoryBot.create(:project_link, {
    :project_id => project.id,
    :name => "Foo Project Link",
    :href => "http://foo.com",
    :link_id => "/resources/foo"
  })
  FactoryBot.create(:project_link, {
    :project_id => project.id,
    :name => "Bar Project Link",
    :href => "http://bar.com",
    :link_id => "/resources/bar"
  })
end

Given /^the "([^"]*)" user is added to the default project$/ do |username|
  cohort = Admin::Cohort.find_by_name('project 1 cohort')
  user = User.find_by_login(username)
  teacher = user.portal_teacher || user.portal_student.teachers.first
  teacher.cohorts << cohort
end

Then /^I should see a project link labeled "([^"]*)" linking to "([^"]*)"$/ do |link, href|
  expect(page).to have_link link
  expect(find_link(link)[:href]).to eq href
end

Then /^I expand the "([^"]*)" section$/ do |section_name|
  # Note: if the section is already expanded this will fail.
  page.find(:xpath,"//*[@id='clazzes_nav']//*[text()='#{section_name}'][not(contains(@class,'open'))]").click
end

Then /^I should not see a project link labeled "([^"]*)"$/ do |link|
  expect(page).to have_no_link link
end
