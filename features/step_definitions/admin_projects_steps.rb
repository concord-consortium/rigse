Given /^the default projects exist using factories$/ do
  Factory.create(:project, name: 'project 1', landing_page_slug: 'project-1')
  Factory.create(:project, name: 'project 2', landing_page_slug: 'project-2')
  Factory.create(:project, name: 'project 3', landing_page_slug: 'project-3')
end

Given /^the project "([^"]+)" has landing page "([^"]+)" and slug "([^"]+)"$/ do |name, page_cont, slug|
  Factory.create(:project, name: name, landing_page_slug: slug, landing_page_content: page_cont)
end

Given /^the following investigations are assigned to projects:$/ do |material_table|
  material_table.hashes.each do |hash|
    inv = Investigation.where(name: hash[:name]).first
    project = Admin::Project.where(name: hash[:project]).first
    inv.projects << project
  end
  reindex_all
end

When /^I click on the edit link for project "([^"]*)"$/ do |name|
  id = Admin::Project.find_by_name(name).id
  with_scope("#admin__project_#{id}") do
    click_link('edit project')
  end
end