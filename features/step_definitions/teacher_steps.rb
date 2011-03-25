When /^I select a school from the list of schools$/ do
  school = Portal::School.first
  When "I select \"#{school.name}\" from \"school_id\""
end

Then /^I should see the the teacher signup form$/ do
  Then I should see "Teacher Signup Page"
  And I should see "personal info"
  And I should see "school"
  And I should see "login info"
end


# Table: | login | password |
Given /^the following teachers exist:$/ do |users_table|
  User.anonymous(true)
  users_table.hashes.each do |hash|
    begin
      user = Factory(:user, hash)
      user.add_role("member")
      user.register
      user.activate
      user.save!
      
      portal_teacher = Factory(:portal_teacher, { :user => user })
      portal_teacher.save!
    rescue ActiveRecord::RecordInvalid
      # assume this user is already created...
    end
  end
end
