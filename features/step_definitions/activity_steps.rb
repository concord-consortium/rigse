Given /^the following activities exist:$/ do |table|
  table.hashes.each do |hash|
    user_name = hash.delete('user')
    user = User.find_by_login user_name

    hash['user'] = user
    Factory :activity, hash
  end
end

When /^I follow "([^"]*)" for the first multiple choice option$/ do |link|
  with_scope("span.small_left_menu") do
    click_link("delete")
  end
end
