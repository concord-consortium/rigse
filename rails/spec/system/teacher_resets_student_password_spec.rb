require 'spec_helper'

RSpec.describe 'Teacher can reset a student\'s password', type: :system do

  it "teacher can reset their student's passwords", js: true do
    visit "/login/teacher"
    classroom = Portal::Clazz.find_by_name("My Class")
    student = FactoryBot.create(:user, first_name: "Johnny", last_name: "McStudent", login: "jmcstudent")
    student.add_role("member")
    student.save!
    student.confirm
    student = FactoryBot.create(:full_portal_student, user: student)
    classroom.students << student

    visit "/portal/classes/#{classroom.id}/roster"
    expect(page).to have_content("Student Roster")
    expect(page).to have_content("McStudent, Johnny")
    expect(page).to have_content("Change Password")

    # Test Change Password button.
    within(:xpath, "//tr[td[contains(text(), 'jmcstudent')]]") do
      find("span", text: "Change Password").click
    end
    expect(page).to have_content("Change Password")
    expect(page).to have_content("Password for Johnny McStudent (jmcstudent)")
    expect(page).to have_content("NEW PASSWORD")
    expect(page).to have_content("CONFIRM NEW PASSWORD")

    # Test password validation.
    fill_in "New Password", with: "123"
    fill_in "Confirm New Password", with: "124"
    click_button "Save"
    expect(page).not_to have_content("Class Name: My Class")
    expect(page).to have_content("Change Password")
    expect(page).to have_content("Your password could not be changed.")
    expect(page).to have_content("Password confirmation doesn't match Password")
    expect(page).to have_content("Password is too short (minimum is 6 characters)")

    # Test valid password change.
    fill_in "New Password", with: "valid_password123"
    fill_in "Confirm New Password", with: "valid_password123"
    click_button "Save"
    expect(page).to have_content("Class Name: My Class")
    expect(page).to have_content("Password for jmcstudent was successfully updated.")

    # Test password change cancellation.
    within(:xpath, "//tr[td[contains(text(), 'jmcstudent')]]") do
      find("span", text: "Change Password").click
    end
    fill_in "New Password", with: "valid_password123"
    fill_in "Confirm New Password", with: "valid_password123"
    click_button "Cancel"
    expect(page).to have_content("Class Name: My Class")
    expect(page).not_to have_content("Password for jmcstudent was successfully updated.")

    # Test student can log in with new password.
    logout()
    login_with_ui_as("jmcstudent", "valid_password123")
    expect(page).to have_content("Welcome,\nJohnny McStudent")
  end
end

