module SystemHelper

  def login_as(username)
    visit "/login/#{username}"
    expect(page).to have_content(username)
  end

  def login_with_ui_as(username, password)
    visit "/users/sign_in"

    within(find(:xpath, "//form[@id='new_user']")) do
      fill_in("user_login",       :with => username)
      fill_in("user_password",    :with => password)
      click_button("Sign in")
    end

    user = User.find_by_login(username)
    user_first_name = user.first_name
    user_last_name = user.last_name
    expect(page).to have_content("Welcome")
    expect(page).to have_content(user_first_name)
    expect(page).to have_content(user_last_name)
  end

  def logout
    visit "/users/sign_out"
    expect(page).to have_content("Signed out successfully.")
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

  def open_class_page(class_name, page_name)
    # Opens the "Classes" menu in the left navbar, clicks on the class name,
    # then clicks on the page name.
    within("#clazzes_nav") do
      find("li", text: "Classes").click
      first("li", text: class_name, exact_text: true).click
      click_link(page_name)
    end
  end

end
