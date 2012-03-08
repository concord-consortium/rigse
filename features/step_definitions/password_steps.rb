When /^I click "([^"]*)" for user: "([^"]*)"$/ do |link, login|
  if link == "Reset Password"
    # find the right update password button
    user = User.find_by_login(login)
    within("#item_user_#{user.id}") do |content|
      click_link "Reset Password"
    end
  else
    pending
  end
end

When /^I click "([^"]*)"$/ do |link|
  click_link link
end
