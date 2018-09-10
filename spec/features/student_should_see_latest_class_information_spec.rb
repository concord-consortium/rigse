require 'spec_helper'

RSpec.feature 'Student should see latest class information' do
  before do
    generate_default_settings_and_jnlps_with_factories

    login_as('teacher')
    clazz = Portal::Clazz.find_by_name('Mathematics')
    visit edit_portal_clazz_path(clazz)
    fill_in('portal_clazz_name', :with => 'Basic Electronics')
    fill_in('portal_clazz_description' , :with => 'This is a biology class')
    fill_in('portal_clazz_class_word' , :with => 'betrx')
    click_button('Save')
    expect(page).not_to have_content('Save')
  end

  scenario 'Student should see the updated class name' do
    login_as('taylor')
    visit root_path
    expect(page).to have_content('Basic Electronics')
  end

  scenario 'Student should see all the updated information of a class', js: true do
    login_as('taylor')
    visit root_path
    first(:link, 'Basic Electronics').click
    expect(page).to have_content('Class Word: betrx')
    expect(page).to have_content('NON LINEAR DEVICES')
    expect(page).to have_content('STATIC DISCIPLINE')
  end
end
