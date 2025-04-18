require 'spec_helper'

RSpec.describe 'Student should see latest class information', type: :system do

  scenario 'Student should see the updated class name', js: true do
    create_class_in_js_context
    login_as("taylor")
    visit "/my_classes"
    expect(page).to have_content('Basic Electronics')
  end

  scenario 'Student should see all the updated information of a class', js: true do
    create_class_in_js_context
    login_as("taylor")
    visit "/my_classes"
    expect(page).to have_content('Basic Electronics')
    first(:link, 'Basic Electronics').click
    expect(page).to have_content('Class Word: betrx')
    expect(page).to have_content('NON LINEAR DEVICES')
    expect(page).to have_content('STATIC DISCIPLINE')
  end

  # moved from before method as this needs to run within the js context to wait for React to render
  def create_class_in_js_context
    login_as("teacher")
    clazz = Portal::Clazz.find_by_name('Mathematics')
    visit edit_portal_clazz_path(clazz)
    fill_in('portal_clazz_name', :with => 'Basic Electronics')
    fill_in('portal_clazz_description' , :with => 'This is a biology class')
    fill_in('portal_clazz_class_word' , :with => 'betrx')
    click_button('Save Changes')
    expect(page).not_to have_content('Save')
    logout()
  end
end
