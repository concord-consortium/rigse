require 'spec_helper'

RSpec.describe "Student can not see deactivated offerings", type: :system do
  before do
    student_user = User.find_by_login("monty")
    student = Portal::Student.find_by_user_id(student_user.id)
    portal_class = Portal::Clazz.find_by_name("class_with_no_students")
    FactoryBot.create(:portal_student_clazz, { :student => student, :clazz => portal_class })
  end

  it "Student should see activated offerings", js: true do
    login_as("monty")
    visit "/my_classes"
    expect(page).to have_content("PLANT REPRODUCTION")
  end

  it "Student should not see deactivated offerings", js: true do
    login_as("teacher")
    visit "/getting_started"
    expect(page).to have_content("Getting Started")
    open_class_page("Class_With_No_Students", "Assignments")
    within("div[class^='sortableItem']", text: "Plant reproduction") do
      first("input[type='checkbox']").uncheck
    end
    logout

    login_as("monty")
    visit "/my_classes"
    expect(page).not_to have_content("PLANT REPRODUCTION")
    expect(page).to have_content("No offerings available.")
  end
end
