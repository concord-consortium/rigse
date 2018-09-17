require 'spec_helper'

RSpec.feature 'Admin configures help page' do
  before do
    FactoryBot.create(:admin_settings)
    login_as('admin')
    visit admin_settings_path
    first(:link, 'edit settings').click
  end

  scenario 'Admin can preview the help page if it has added HTML', js: true do
    fill_in('admin_settings[custom_help_page_html]', :with => 'Creating Help Page')
    click_button('Preview Custom Help Page')
    in_newly_opened_window do
      expect(page).to have_content('Creating Help Page')
      close_window
    end
  end

  scenario 'Admin can add an external URL for the help page', js: true do
    choose('Use external help URL')
    check('Mark these settings as active:')
    fill_in('admin_settings[external_url]', :with => 'www.google.com')
    click_save
    first(:link, 'edit settings').click
    expect(page).to have_xpath "//input[@name='admin_settings[external_url]' and @value = 'http://www.google.com']"
    visit '/home'
    within('div#clazzes_nav') { first(:link, 'Help').click }
    in_newly_opened_window do
      expect(page).to have_content('Gmail')
      close_window
    end
  end

  scenario 'Admin can add custom HTML for the help page', js: true do
    choose('Use custom help page HTML')
    check('Mark these settings as active:')
    fill_in('admin_settings[custom_help_page_html]', :with => 'Creating Help Page')
    click_save
    visit '/search'
    first(:link, 'Help').click
    in_newly_opened_window do
      expect(page).to have_content('Creating Help Page')
      close_window
    end
  end

  scenario 'Admin can preview the help page if it is an external URL', js: true do
    fill_in('admin_settings[external_url]', :with => 'www.google.com')
    click_button('Preview External Help URL')
    in_newly_opened_window do
      expect(page).to have_content('Gmail')
      close_window
    end
  end

  scenario 'Admin should see errors on saving the settings if text boxes are blank', js: true do
    fill_in('admin_settings[custom_help_page_html]', :with => '')
    choose('Use custom help page HTML')
    click_button 'Save'
    expect_text_within_lightbox('Custom HTML cannot be blank if selected as the help page.')
    visit admin_settings_path
    first(:link, 'edit settings').click
    fill_in('admin_settings[external_url]', :with => '')
    choose('Use external help URL')
    click_button 'Save'
    expect_text_within_lightbox('Please enter a valid external help URL.')
  end

  scenario 'Admin should see errors on previewing the the help page if text boxes are blank', js: true do
    fill_in('admin_settings[custom_help_page_html]', :with => '')
    click_button 'Preview Custom Help Page'
    expect_text_within_lightbox('Please enter some custom help HTML to preview.')
    visit admin_settings_path
    first(:link, 'edit settings').click
    fill_in('admin_settings[external_url]', :with => '')
    click_button('Preview External Help URL')
    expect_text_within_lightbox('Please enter a valid external help URL.')
  end

  scenario 'Admin should be allowed to remove help page link', js: true do
    choose('No help link')
    click_save
    expect(page).to have_content('No Help Page')
    visit '/help'
    expect(page).to have_content('There is no help available for this site.')
    visit '/search'
    within('div#clazzes_nav') { expect(page).not_to have_content('Help') }
  end

  def click_save
    click_button 'Save'
    expect(page).to have_no_button('Save')
  end

  def expect_text_within_lightbox(text)
    within('div.ui-window.lightbox.lightbox_focused') { expect(page).to have_content(text) }
  end
end
