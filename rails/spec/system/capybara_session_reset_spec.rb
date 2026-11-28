require 'spec_helper'

RSpec.describe 'Capybara session reset', type: :system do
  def cookie_names
    page.driver.browser.manage.all_cookies.map { |cookie| cookie[:name] }
  end

  it 'clears cookies and local storage between tests' do
    visit '/'
    page.driver.browser.manage.add_cookie(name: 'reset_probe', value: '1')
    page.execute_script("localStorage.setItem('reset_probe', '1')")
    expect(cookie_names).to include('reset_probe')
    expect(page.evaluate_script("localStorage.getItem('reset_probe')")).to eq('1')

    Capybara.reset_sessions!
    visit '/'

    expect(cookie_names).not_to include('reset_probe')
    expect(page.evaluate_script("localStorage.getItem('reset_probe')")).to be_nil
  end
end
