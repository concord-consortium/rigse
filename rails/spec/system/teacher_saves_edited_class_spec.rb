require 'spec_helper'

RSpec.describe "Teacher edits and saves class information", type: :system do
  let(:teacher_list) { find("#div_teacher_list") }
  let(:class_name_input) { find("#portal_clazz_name") }

  before do
    login_as("teacher")
    visit "/getting_started"

    # Click on the Mathematics class's setup link
    within("#clazzes_nav") do
      find("li", text: "Classes").click
      first("li", text: "Mathematics", exact_text: true).click
      click_link("Class Setup")
    end
  end

  def add_teacher(teacher_name)
    within(find("#teacher_id_selector")) do
      first("option", text: teacher_name).select_option
    end
    click_button("Add")
  end

  def remove_teacher(teacher_name)
    within(teacher_list) do
      accept_alert do
        within(:xpath, "//li[contains(text(), '#{teacher_name}')]") do
          find("span").click
        end
      end
    end
  end

  it "Teacher can see all the teachers in the class", js: true do
    expect(class_name_input.value).to eq("Mathematics")
    expect(teacher_list).to have_content("Taylor, P. (peterson)")
    expect(teacher_list).to have_content("Nash, J. (teacher)")
  end

  it "Teacher can add a teacher from the class edit page", js: true do
    expect(class_name_input.value).to eq("Mathematics")
    expect(teacher_list).not_to have_content("Fernandez, R. (robert)")

    add_teacher("Fernandez, R. (robert)")

    expect(class_name_input.value).to eq("Mathematics")
    expect(teacher_list).to have_content("Fernandez, R. (robert)")
  end

  it "Teacher can remove a teacher from the class edit page", js: true do
    expect(class_name_input.value).to eq("Mathematics")
    expect(teacher_list).to have_content("Taylor, P. (peterson)")

    remove_teacher("Taylor, P. (peterson)")

    expect(class_name_input.value).to eq("Mathematics")
    expect(teacher_list).not_to have_content("Taylor, P. (peterson)")
  end

  it "Teacher can remove themselves from the class edit page", js: true do
    expect(class_name_input.value).to eq("Mathematics")
    expect(teacher_list).to have_content("Nash, J. (teacher)")

    remove_teacher("Nash, J. (teacher)")

    expect(class_name_input.value).to eq("Mathematics")
    expect(teacher_list).not_to have_content("Nash, J. (teacher)")
  end

  it "Teacher saves class setup information", js: true do
    expect(class_name_input.value).to eq("Mathematics")

    fill_in("portal_clazz_name", with: "Basic Electronics")
    fill_in("portal_clazz_description", with: "This is a biology class")
    fill_in("portal_clazz_class_word", with: "BETRX")
    click_button("Save Changes")

    expect(page).to have_content("Assignments for Basic Electronics")
    expect(page).to have_content("Class was successfully updated.")
  end
end
