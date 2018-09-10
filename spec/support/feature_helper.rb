module FeatureHelper
  def login_as(username)
    visit "/login/#{username}"
    expect(page).to have_content(username)
  end

  def in_newly_opened_window
    sleep(2)
    page.driver.browser.switch_to.window(page.driver.browser.window_handles.last) do
      yield
    end
  end

  def close_window
    page.execute_script "window.close();"
  end
end