require 'spec_helper'

RSpec.describe 'Admin can add, edit and remove notices', type: :system, WebDriver: true do

  before do
    visit "/login/admin"
  end

  def create_notice(content)
    visit "/admin/site_notices"
    expect(page).to have_content("Create New Notice")

    click_link "Create New Notice"
    expect(page).to have_content("Create Notice")
    expect(page).to have_css("iframe#notice_html_ifr")

    within_frame("notice_html_ifr") do
      editor_body = find("body")
      expect(editor_body).to be_present
      execute_script("arguments[0].innerHTML = '#{content}'", editor_body)
    end

    click_button "Publish Notice"
    expect(page).to have_content("Notices")
    expect(page).to have_content(content)
  end

  it "admin can add a notice", js: true do
    create_notice("Notice for users")

    visit "/getting_started"
    expect(page).to have_content("Notices")
    expect(page).to have_content("HIDE NOTICES")
    expect(page).to have_content("Notice for users")
  end

  it "admin cannot publish blank notices", js: true do
    visit "/admin/site_notices"
    expect(page).to have_content("Create New Notice")

    click_link "Create New Notice"
    expect(page).to have_content("Create Notice")

    click_button "Publish Notice"
    expect(page).to have_content("Notice text is blank")
  end

  it "admin can edit notices", js: true do
    create_notice("Notice for admin")

    click_link "edit"
    expect(page).to have_content("Edit Notice")
    expect(page).to have_css("iframe#notice_html_ifr")

    within_frame("notice_html_ifr") do
      editor_body = find("body")
      expect(editor_body).to be_present
      execute_script("arguments[0].innerHTML = 'Edited notice for users'", editor_body)
    end

    click_button "Update Notice"
    expect(page).to have_content("Edited notice for users")
    expect(page).not_to have_content("Notice for admin")
  end

  it "admin can remove notices", js: true do
    create_notice("Notice for admin")

    accept_alert "Are you sure you want to delete this notice?" do
      find("a[title='Delete Notice']").click
    end
    expect(page).not_to have_content("Notice for admin")
  end

  it "admin can cancel notice creation", js: true do
    visit "/admin/site_notices"
    expect(page).to have_content("Create New Notice")

    click_link "Create New Notice"
    expect(page).to have_css("iframe#notice_html_ifr")

    within_frame("notice_html_ifr") do
      editor_body = find("body")
      expect(editor_body).to be_present
      execute_script("arguments[0].innerHTML = 'Notice for admin'", editor_body)
    end

    click_link "Cancel"
    expect(page).not_to have_content("Notice for admin")
  end

  it "admin can cancel notice editing", js: true do
    create_notice("Notice for admin")

    click_link "edit"
    expect(page).to have_content("Edit Notice")
    expect(page).to have_css("iframe#notice_html_ifr")

    within_frame("notice_html_ifr") do
      editor_body = find("body")
      expect(editor_body).to be_present
      execute_script("arguments[0].innerHTML = 'Edited notice for users'", editor_body)
    end

    click_link "Cancel"
    expect(page).not_to have_content("Edited notice for users")
    expect(page).to have_content("Notice for admin")
  end

  it "admin is shown a message if there are no notices", js: true do
    visit "/admin/site_notices"
    expect(page).to have_content("Notices")
    expect(page).to have_content("You have no notices.")
  end
end
