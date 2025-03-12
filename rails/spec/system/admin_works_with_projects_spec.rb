require 'spec_helper'

RSpec.describe 'Admin can work with projects', type: :system do

  before do
    FactoryBot.create(:project, name: "project 1", landing_page_slug: "project-1")
    FactoryBot.create(:project, name: "project 2", landing_page_slug: "project-2")
    FactoryBot.create(:project, name: "project 3", landing_page_slug: "project-3")

    visit "/login/admin"
  end

  it "Admin accesses projects", js: true do
    visit "/admin/projects"

    expect(page).to have_content("Displaying all 4 projects")
    expect(page).to have_content("default data project")
    expect(page).to have_content("project 1")
    expect(page).to have_content("project 2")
    expect(page).to have_content("project 3")
    expect(page).to have_content("Create Project")
  end

  it "Admin creates a new project", js: true do
    visit "/admin/projects"

    click_link "create Project"
    fill_in "admin_project[name]", with: "My new project"
    fill_in "admin_project[landing_page_slug]", with: "new-project"
    fill_in "admin_project[landing_page_content]", with: "<h1>New project FooBar!</h1>"

    click_button "Save"
    expect(page).to have_content("Displaying all 5 projects")
    expect(page).to have_content("Project was successfully created.")
    expect(page).to have_content("My new project")

    click_link "new-project"
    expect(page).to have_current_path("/new-project")
    expect(page).to have_content("New project FooBar!")
  end

  it "Admin creates a new project providing invalid params", js: true do
    visit "/admin/projects"

    click_link "create Project"
    click_button "Save"
    expect(page).to have_content("there are errors")
    expect(page).to have_content("Name can't be blank")

    fill_in "admin_project[name]", with: "My new project"
    fill_in "admin_project[landing_page_slug]", with: "project-1"
    click_button "Save"
    expect(page).to have_content("there are errors")
    expect(page).to have_content("Landing page slug has already been taken")

    fill_in "admin_project[landing_page_slug]", with: "invalid/slug"
    click_button "Save"
    expect(page).to have_content("there are errors")
    expect(page).to have_content("Landing page slug only allows lower case letters, digits and '-' character")
  end

  it "Admin edits existing project", js: true do
    visit "/admin/projects"

    within find(".container_element", text: "project 1") do
      click_link "edit"
    end
    fill_in "admin_project[name]", with: "New project name"
    click_button "Save"
    expect(page).to have_content("Project was successfully updated.")
    expect(page).to have_content("New project name")
    expect(page).not_to have_content("project 1")
  end

  it "Admin adds a link to an existing project", js: true do
    visit "/admin/projects"

    within find(".container_element", text: "project 2") do
      click_link "edit"
    end
    click_link "Add a link"
    fill_in "admin_project_link[name]", with: "New project link"
    fill_in "admin_project_link[link_id]", with: "new-id"
    fill_in "admin_project_link[href]", with: "https://www.google.com/"
    click_button "Save"
    expect(page).to have_content("ProjectLink was successfully created.")
  end

  it "Admin edits existing project providing invalid params", js: true do
    visit "/admin/projects"

    within find(".container_element", text: "project 2") do
      click_link "edit"
    end
    fill_in "admin_project[name]", with: ""
    click_button "Save"
    expect(page).to have_content("there are errors")
    expect(page).to have_content("Name can't be blank")

    fill_in "admin_project[name]", with: "new project 2"
    fill_in "admin_project[landing_page_slug]", with: "project-1"
    click_button "Save"
    expect(page).to have_content("there are errors")
    expect(page).to have_content("Landing page slug has already been taken")
  end

  it "Admin adds materials to a project", js: true do
    pending "Testing search not working yet."
    visit "/search"
    fill_in "search_term", with: "testing fast cars"
    click_button "Go"
    click_link "portal settings"
    expect(page).to have_content("Projects")
    expect(page).to have_content("project 1")
    expect(page).to have_content("project 2")
    expect(page).to have_content("project 3")
    check "project 1"
    click_button "Save"
    expect(page).to have_content("Collections")
    expect(page).to have_content("project 1")
  end

  it "Admin filters search results based on projects", js: true do
    pending "Testing search not working yet."
    visit "/search"
    expect(page).to have_content("Collections")
    expect(page).to have_content("project 1")
    expect(page).to have_content("project 2")
    expect(page).not_to have_content("project 3")
    check "project 1"
    expect(page).to have_content("Radioactivity")
    expect(page).not_to have_content("Set Theory")
    expect(page).not_to have_content("Mechanics")
    uncheck "project 1"
    check "project 2"
    expect(page).not_to have_content("Radioactivity")
    expect(page).to have_content("Set Theory")
    expect(page).to have_content("Mechanics")
  end

end
