Given /^the following students exist:$/ do |table|
  table.hashes.each do |hash|
    begin
      clazz = Portal::Clazz.find_by_name(hash.delete('class'))
      user = Factory(:user, hash)
      user.add_role("member")
      user.save!
      user.confirm!

      portal_student = Factory(:full_portal_student, { :user => user })
      portal_student.save!
      if (clazz)
        portal_student.add_clazz(clazz)
      end
    rescue ActiveRecord::RecordInvalid
      # assume this user is already created...
    end
  end
end

# And the student "student_a" is in the class "intro to bugs"
Given /^the student "([^"]*)" is in the class "([^"]*)"$/ do |student_name, class_name|
  student = User.find_by_login(student_name).portal_student
  clazz   = Portal::Clazz.find_by_name(class_name)
  student.add_clazz(clazz)
end

Given /^the student "(.*)" belongs to class "(.*)"$/ do |student_name, class_name|
  student = User.find_by_login(student_name).portal_student
  clazz   = Portal::Clazz.find_by_name(class_name)

  Factory.create :portal_student_clazz, :student => student,
                                        :clazz   => clazz
end

Given /^the student "([^"]*)" has security questions set$/ do |student_login|
  user = User.find_by_login student_login
  student = Portal::Student.find_by_user_id user.id

  questions = []
  #"What is your favorite color?"
  questions << SecurityQuestion.new({ :question => SecurityQuestion::QUESTIONS[0], :answer => "red" })
  #"What is your favorite food?"
  questions << SecurityQuestion.new({ :question => SecurityQuestion::QUESTIONS[1], :answer => "pizza" })
  #"What is your favorite ice cream flavor?"
  questions << SecurityQuestion.new({ :question => SecurityQuestion::QUESTIONS[2], :answer => "chocolate" })

  student.user.security_questions << questions
  student.save
end

Given /^the student "([^"]*)" has no security questions set$/ do |student_login|
  user = User.find_by_login student_login
  student = Portal::Student.find_by_user_id user.id
  student.user.security_questions = []
  student.save
end

Then /^the student "([^"]*)" should belong to the class "([^"]*)"$/ do |student_login, class_name|
  user = User.find_by_login student_login
  student = Portal::Student.find_by_user_id user.id
  clazz = Portal::Clazz.find_by_name class_name
  student.clazzes.should include clazz
end

When /^(?:|I )run the (?:investigation|activity|external activity|resource page)$/ do
  # make sure the current user is a student
  user = User.find_by_login(@cuke_current_username)
  user.portal_student.should_not == nil

  # note this isn't an exact match sometimes the link is Run by Myself, sometimes it is just Run
  # and addtionally if groups are turned on then there will be another link that is Run with Other Students
  find(".solo.button").click
end

Then /^I should see the run link for "([^"]*)"$/ do | runnable_name |
  within(".offering_for_student:contains('#{runnable_name}')") do
    page.should have_selector('.solo.button')
  end
end

Then /^I should not see the run link for "([^"]*)"$/ do | runnable_name |
  page.should_not have_content(runnable_name)
end

Given /^the student report is disabled for the (activity|investigation|external activity) "([^"]+)"$/ do |type, name|
  material = nil
  case type
    when "investigation"
      material = Investigation.find_by_name(name)
    when "activity"
      material = Activity.find_by_name(name)
    when "external activity"
      material = ExternalActivity.find_by_name(name)
  end

  material.student_report_enabled = false
  material.save!
end
