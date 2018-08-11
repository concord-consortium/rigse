Given /^I am not logged in$/ do
  # pending # express the regexp above with the code you wish you had
  # controller.current_visitor = User.anonymous
end

When /^I visit the route (.+)$/ do |path|
  visit path
end

Then /^I should be redirected (.+)$/ do |named_route|
  expect(response).to redirect_to(named_route)
end

Then /^I should not be redirected (.+)$/ do |named_route|
  expect(response).not_to redirect_to(named_route)
end
