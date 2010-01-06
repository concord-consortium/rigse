Given /^I am an anonymous user$/ do
  true #  for now ...
end

Then /^I should see the the teacher signup form$/ do
  Then I should see "Teacher Signup Page"
  And I should see "personal info"
  And I should see "school"
  And I should see "login info"
end