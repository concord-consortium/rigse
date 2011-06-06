Given /^the following tests exist:$/ do |table|
  user = Factory :user
  user.register
  user.activate
  user.save!
  table.hashes.each do |hash|
    hash['user'] = user
    Factory :page, hash
  end
end

Given /^the teacher "([^"]*)" is in cohort "([^"]*)"$/ do |login, cohort|
  user = User.find_by_login(login)
  user.portal_teacher.cohort_list = cohort
  user.portal_teacher.save
end
