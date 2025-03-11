require 'spec_helper'

RSpec.describe 'Teacher removes a student', type: :system do

  before do
    visit "/login/teacher"
  end

  it "removes a student from a class", js: true do
    classroom = Portal::Clazz.find_by_name("Class_with_no_students")
    student = FactoryBot.create(:user, first_name: "Johnny", last_name: "McStudent", login: "jmcstudent")
    student.add_role("member")
    student.save!
    student.confirm
    student = FactoryBot.create(:full_portal_student, user: student)
    classroom.students << student

    visit "/portal/classes/#{classroom.id}/roster"
    expect(page).not_to have_content("No students registered for this class yet.")
    expect(page).to have_content("Student Roster")
    expect(page).to have_content("McStudent, Johnny")
    expect(page).to have_content("Remove Student")

    accept_alert do
      find("span", text: "Remove Student").click
    end

    expect(page).to have_content("No students registered for this class yet.")
  end
end
