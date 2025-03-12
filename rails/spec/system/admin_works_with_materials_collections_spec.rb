require "spec_helper"

RSpec.describe "Admin can work with materials collections", type: :system do

  before do
    FactoryBot.create(:project, name: "project 1", landing_page_slug: "project-1")
    FactoryBot.create(:project, name: "project 2", landing_page_slug: "project-2")
    FactoryBot.create(:project, name: "project 3", landing_page_slug: "project-3")

    visit "/login/admin"
  end

  it "Admin accesses materials collections", js: true do
    visit "/getting_started"
    expect(page).to have_content("Admin")
    click_link "Admin"
    expect(page).to have_content("Materials Collections")
    all("a", text: "Materials Collections").first.click

    expect(page).to have_content("Displaying all 4 materials collections")
    expect(page).to have_content("Create Materials Collection")
  end

  it "Admin creates a new materials collection", js: true do
    visit "/materials_collections"

    click_link "create Materials Collection"
    fill_in "materials_collection[name]", with: "My new Collection"
    select "project 1", from: "materials_collection[project_id]"
    expect(page).to have_css("iframe#materials_collection_description_ifr")

    within_frame("materials_collection_description_ifr") do
      editor_body = find("body")
      expect(editor_body).to be_present
      execute_script("arguments[0].innerHTML = 'My new Description'", editor_body)
    end

    click_button "Save"
    expect(page).to have_content("Materials Collection was successfully created.")
    expect(page).to have_content("My new Collection")
  end

  it "Admin views existing materials collection via the show link", js: true do
    collection_1_id = MaterialsCollection.find_by(name: "Collection 1").id
    visit "/materials_collections"

    click_link "default data project: Collection 1"
    expect(page).to have_current_path("/materials_collections/#{collection_1_id}")
    expect(page).to have_content("default data project: Collection 1")
    expect(page).to have_content("List materials collections")

    click_link "List materials collections"
    expect(page).to have_current_path("/materials_collections")
  end

  it "Admin edits existing materials collection", js: true do
    visit "/materials_collections"

    click_link "edit", match: :first
    fill_in "materials_collection[name]", with: "My new Collection edits"

    within_frame("materials_collection_description_ifr") do
      editor_body = find("body")
      expect(editor_body).to be_present
      execute_script("arguments[0].innerHTML = 'My new Description'", editor_body)
    end

    click_button "Save"
    expect(page).to have_content("My new Collection edits")
  end

  # testing search is not working yet
  # it "Admin adds materials to a Materials Collection", js: true do
  #   author = User.find_by(login: "author")
  #   FactoryBot.create(:external_activity, name: "testing fast cars", user: author)
  #   visit "/search"

  #   fill_in "search_term", with: "testing fast cars"
  #   click_button "Go"
  #   expect(page).to have_content("Add to Collection")
  #   click_link "Add to Collection"
  #   expect(page).to have_content("Select Collection(s)")
  #   expect(page).to have_content("Collection 1")
  #   expect(page).to have_content("Collection 4")
  #   expect(page).not_to have_content("Already assigned to the following collections")
  #   expect(page).to have_current_path("/search")
  #   check "Collection 1"
  #   click_button "Save"
  #   expect(page).not_to have_content("Collection 1")
  #   expect(page).not_to have_content("Collection 4")
  #   expect(page).to have_content("testing fast cars is assigned to the selected collection(s) successfully")
  #   click_button "OK"
  #   click_link "Add to Collection"
  #   expect(page).to have_content("Select Collection(s)")
  #   expect(page).to have_content("Already assigned to the following collection(s)")
  # end

  it "Admin deletes existing materials collection", js: true do
    visit "/materials_collections"

    click_link "delete", match: :first
    page.accept_confirm
    expect(page).not_to have_content("Collection 1")
  end

  it "Admin cancels deleting existing materials collection", js: true do
    visit "/materials_collections"

    click_link "delete", match: :first
    page.dismiss_confirm
    expect(page).to have_content("Collection 2")
  end

end
