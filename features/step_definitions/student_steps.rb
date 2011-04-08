Given /^the following students exist:$/ do |table|
  User.anonymous(true)
  table.hashes.each do |hash|
    begin
      clazz = Portal::Clazz.find_by_name(hash.delete('class'))
      user = Factory(:user, hash)
      user.add_role("member")
      user.register
      user.activate
      user.save!

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

Then /^the student "([^"]*)" should belong to the class "([^"]*)"$/ do |student_login, class_name|
  user = User.find_by_login student_login
  student = Portal::Student.find_by_user_id user.id
  clazz = Portal::Clazz.find_by_name class_name
  student.clazzes.should include clazz
end
