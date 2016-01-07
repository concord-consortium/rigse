Given /^the default project links exist using factories$/ do
  project = Factory.create(:project, name: 'project 1', landing_page_slug: 'project-1')
  Factory(:admin_cohort, {
    :project_id => project.id,
    :name => 'project 1 cohort'
  })
  Factory(:project_link, {
    :project_id => project.id,
    :name => "Foo Project Link",
    :href => "http://foo.com"
  })
  Factory(:project_link, {
    :project_id => project.id,
    :name => "Bar Project Link",
    :href => "http://bar.com"
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

Then /^I should not see a project link labeled "([^"]*)"$/ do |link|
  expect(page).to have_no_link link
end

