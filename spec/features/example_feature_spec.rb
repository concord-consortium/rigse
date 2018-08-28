require "spec_helper"

RSpec.feature "Example Feature Spec" do
  scenario "When using Rack Test, it works" do
    visit "/users"
    expect(page).to have_text("Log in with your Rails Portal (development) account.")
  end

  scenario "When using Chrome, it works", js: true do
    visit "/users"
    expect(page).to have_text("Log in with your Rails Portal (development) account.")
  end
end
