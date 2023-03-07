Given("a project called {string}") do |name|
  FactoryBot.create(:project, name: name)
end

Given("the default projects exist using factories") do
  FactoryBot.create(:project, name: "project 1", landing_page_slug: "project-1")
  FactoryBot.create(:project, name: "project 2", landing_page_slug: "project-2")
  FactoryBot.create(:project, name: "project 3", landing_page_slug: "project-3")
end

When /^I click on the (id|edit|delete) link for project "([^"]*)"$/ do |link_type, name|
  id = Admin::Project.find_by_name(name).id
  link = case link_type
    when "id"
      "#{id}"
    when "edit"
      "edit"
    when "delete"
      "delete"
    else
      raise "Invalid project collection link type: #{link_type}"
    end

  with_scope("#admin__project_#{id}") do
    click_link(link)
  end
end
