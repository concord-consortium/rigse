require 'spec_helper'

RSpec.describe "A manager updates account information for another user", type: :system do
  let(:student_user) { User.find_by(login: "student") }
  let(:student_full_name) { "#{student_user.first_name} #{student_user.last_name}" }
  let(:new_user) { FactoryBot.create(:user, first_name: "New", last_name: "User", login: "justsignedup") }
  let(:new_user_full_name) { "#{new_user.first_name} #{new_user.last_name}" }

  before do
    login_as("mymanager")
  end

  it "Manager can change a user's email address", js: true do
    user_preferences_path = preferences_user_path(student_user)
    visit user_preferences_path
    expect(page).to have_content("User Preferences")
    expect(find_field("user_email").value).to eq("student@mailinator.com")
    fill_in "user_email", with: "test1@mailintator.com"
    click_button "Save"
    expect(page).to have_content("User: #{student_full_name} was successfully updated.")
    visit user_preferences_path
    expect(find_field("user_email").value).to eq("test1@mailintator.com")
  end

  it "Managers can change a users password", js: true do
    visit users_path
    fill_in "search", with: student_full_name
    click_button "Search"
    expect(page).to have_content(student_full_name)
    within(".action_menu", text: student_full_name) do
      click_link "Reset Password"
    end
    expect(page).to have_content("Password for #{student_full_name} (#{student_user.login})")
    fill_in "user_reset_password_password", with: "newpassword"
    fill_in "user_reset_password_password_confirmation", with: "newpassword"
    click_button "Save"
    expect(page).to have_content("Password for #{student_user.login} was successfully updated.")
    logout
    login_with_ui_as(student_user.login, "newpassword")
    expect(page).to have_content("Welcome,\n#{student_full_name}")
  end

  it "Managers can activate users", js: true do
    visit users_path
    fill_in "search", with: new_user_full_name
    click_button "Search"
    expect(page).to have_content(new_user_full_name)
    within(".action_menu", text: new_user_full_name) do
      click_link "Activate"
    end
    expect(page).to have_content("Activation of User, #{new_user.first_name} ( #{new_user.login} ) complete.")
  end
end
