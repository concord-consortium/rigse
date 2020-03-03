require 'spec_helper'

RSpec.feature 'Admin goes to user page', :WebDriver => true do
  before do
    login_as('admin')
    visit users_path
  end

  scenario 'Admin can view user page', js: true do
    expect(current_path).to eq '/users'
    expect(page.body).to match(%r{#{'Show/Hide User Descriptions'}}i)
  end

  scenario 'Admin can edit a user', js: true do
    first('.action_menu_header_right .menu .menu').click_link('edit')
    expect(current_path).to eq '/users/1/edit'
    find(:xpath, "//input[@id='user_first_name']").set "Jim"
    click_button('Save')
    expect(current_path).to eq '/users'
    expect(page.body).to match(%r{#{'successfully updated'}}i)
  end
end
