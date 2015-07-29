Given /^the default project links exist using factories$/ do
  project = Factory.create(:project, name: 'project 1', landing_page_slug: 'project-1')
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
  userId = User.find_by_login(username).id
  projectId = Admin::Project.find_by_name('project 1').id
  Factory(:project_user, {
    :project_id => projectId,
    :user_id => userId
  })
end

Then /^I should see a project link labeled "([^"]*)" linking to "([^"]*)"$/ do |link, href|
  expect(page).to have_link link
  expect(find_link(link)[:href]).to eq href
end

Then /^I should not see a project link labeled "([^"]*)"$/ do |link|
  expect(page).to have_no_link link
end

