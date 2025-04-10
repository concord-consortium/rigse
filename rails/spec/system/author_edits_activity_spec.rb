require 'spec_helper'

RSpec.describe 'Admin configures help page', type: :system do
  let (:authored_activity) {
    # find activity owned by author
    user = User.where(login: 'author').first
    ExternalActivity.where(user_id: user.id).first
  }

  before do
    login_as("admin")
  end

  scenario 'Author can view the edit the page for their activity', js: true do
    visit matedit_external_activity_path(authored_activity)
    expect(page).to have_content("Edit #{authored_activity.name}")
  end

  scenario 'Author can archive their activity', js: true do
    visit matedit_external_activity_path(authored_activity)
    # this will raise an error if it can't be clicked
    page.find_link("Archive").click
  end

  scenario 'Author can assign the activity to a class', js: true do
    visit matedit_external_activity_path(authored_activity)
    # this will raise an error if it can't be clicked
    page.find_link("Assign or Share").click
  end
end
