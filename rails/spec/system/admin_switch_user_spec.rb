require 'spec_helper'

RSpec.describe 'Admin switches to a different user', type: :system do

  it "allows an admin to switch to another user and back again", js: true do
    visit "/login/admin"

    visit "/users"
    expect(page).to have_content("Account Report")

    fill_in "search", with: "Switchuser"
    click_button "Search"

    expect(page).to have_content("Joe Switchuser")
    within(".action_menu", text: "Joe Switchuser") do
      click_link "Switch"
    end

    expect(page).to have_content("Welcome,")
    expect(page).to have_content("Joe Switchuser")
    expect(page).not_to have_content("joe user")

    click_link "Switch back"

    expect(page).to have_content("Welcome,")
    expect(page).to have_content("joe user")
    expect(page).not_to have_content("Joe Switchuser")
  end
end
