Then /^the teachers "([^"]*)" are in a school named "([^"]*)"$/ do |teachers,school_name|
  school = Portal::School.find_by_name(school_name)
  if (school.nil?) then
    school = FactoryBot.create(:portal_school, :name=>school_name)
  end
  teachers = teachers.split(",").map { |t| t.strip }
  teachers.map! {|t| User.find_by_login(t)}
  teachers.map! {|u| u.portal_teacher }
  teachers.each {|t| t.schools = [ school ]; t.save!; t.reload}
end

# Table: | login | password |
Given /^the following teachers exist:$/ do |users_table|
  users_table.hashes.each do |hash|
    begin
      user = FactoryBot.create(:user, hash)
      user.add_role("member")
      user.save!
      user.confirm!


      portal_teacher = FactoryBot.create(:portal_teacher, { :user => user })
      portal_teacher.save!

    rescue ActiveRecord::RecordInvalid
      # assume this user is already created...
    end
  end
end


Given /^the following teacher and class mapping exists:$/ do |teacher_clazz|
  teacher_clazz.hashes.each do |hash|
    portal_clazz = Portal::Clazz.find_by_name(hash['class_name'])
    user = User.find_by_login(hash['teacher'])
    portal_teacher = Portal::Teacher.find_by_user_id(user.id)
    teacher_clazz = Portal::TeacherClazz.new()
    teacher_clazz.clazz_id = portal_clazz.id
    teacher_clazz.teacher_id = portal_teacher.id
    save_result = teacher_clazz.save
    if (save_result == false)
      return save_result
    end
  end
end

When /^I run the student's investigation for "([^"]+)"$/ do |clazz_name|
  step_text = "I am on the class page for \"#{clazz_name}\""
  step step_text
  within(".accordion_content") do
    click_link 'Run'
  end
end

When /^I uncheck Active for the external activity "(.*)"$/ do |material_name|
  # find span containing material name, then uncheck the associated checkbox
  find('span', text: material_name).first(:xpath, './following-sibling::span').find('input[type="checkbox"]').set(false)
end
