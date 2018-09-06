require "spec_helper"

RSpec.feature "Feature specs should use seeded database" do
  scenario "Teacher should exist", js: true do
    username = 'teacher'
    visit "/login/#{username}"
    expect(page).to have_content(username)
  end
end
