require "spec_helper"

RSpec.describe "Admin configures help page", type: :system do

  before do
    FactoryBot.create(:admin_settings)
    login_as("admin")
    visit admin_settings_path
  end

  scenario "Admin can add an external URL for the help page" do
    first(:link, "edit settings").click
    choose "Use external help URL"
    check "Mark these settings as active:"
    fill_in "admin_settings[external_url]", with: "https://www.google.com"
    click_save
    visit "/help"
    expect(page.current_url).to match(/^https:\/\/www\.google\.com/)
  end

  scenario "Admin can add custom HTML for the help page" do
    first(:link, "edit settings").click
    choose "Use custom help page HTML"
    check "Mark these settings as active:"
    fill_in "admin_settings[custom_help_page_html]", with: "custom help text Page"
    click_save
    visit "/help"
    expect_content "custom help text Page"
  end

  scenario "Admin should be allowed to remove help page link" do
    first(:link, "edit settings").click
    choose "No help link"
    click_save
    expect_content "No Help Page"
    visit "/help"
    expect_content "There is no help available for this site."
  end

  def click_save
    click_button "Save"
    expect(page).to have_no_button("Save")
  end

  def expect_content(text)
    expect(page).to have_content(text)
  end
end
