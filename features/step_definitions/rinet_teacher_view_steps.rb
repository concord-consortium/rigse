#
# Setup a teacher with courses.
#
Given /a rinet teacher/i do
  @rinet_login = "bowb_dobs"
  @rites_login = ExternalUserDomain.external_login_to_login(@rinet_login)
  @user = Factory(:user, {
    :login => @rites_login
  });
  @user.register
  @user.activate
  @teacher = Factory(:portal_teacher, {
    :user => @user
  })
  @school = Factory(:nces_portal_school)
  @school.add_member(@teacher)
  @course_names = ["physics", "geometry", "chemestry"]
  @clazzes = []
  @course_names.each do |c_name| 
    course = Factory(:portal_course, {
      :school => @school,
      :name => c_name
    })
    clazz = Factory(:portal_clazz, {
      :course => course,
      :name => c_name,
      :teacher => @teacher
    })
    @clazzes << clazz
  end
  @student_rinet_logins = ["lpaessel", "adda_p", "npaessel", "knowuh", "hannah"]
  @student_rinet_logins.each do | login |
    rites_login = ExternalUserDomain.external_login_to_login(login)
    user = Factory(:user, {
      :login => rites_login
    })
    user.register
    user.activate
    student = Factory(:portal_student, {
      :user => user
    })
    @school.add_member(student)
    @clazzes.each do |clazz|
      student.add_clazz(clazz)
    end
  end
  @teacher.save
  @teacher.reload
end



 
When /I login with the link\s*tool/ do
 visit('/linktool', :get, {:serverurl => "http://moleman.concord.org/", :internaluser => @rinet_login})
end

Then /^I should be forwarded to my home page$/ do
 response.status.should == "200 OK"
 response.body.should include("Welcome to RITES Investigations")
 response.body.should match(/Welcome\n\s*#{@teacher.user.name}/)
end
 

Then /I should see a list of my classes$/ do 
   response.body.should match(/classes:/i)
   @course_names.each do |course_name|
     response.body.should match(course_name)
   end
end

When /I look at my first classes page/ do 
  visit("/portal/clazzes/#{@teacher.clazzes.first.id}")
end


Then /^I should see a list of my students$/ do
  clazz = @teacher.clazzes.first
  students = clazz.students
  students.each do | student |
    response.body.should match(student.login)
  end
end

# Actions
#
# When "$actor goes to the link tool url" do |_|
#   visit('/linktool', :get, {:serverurl => "http://moleman.concord.org/", :internaluser => @rinet_login})
# end
# 
# #
# # Result
# #
# Then "$actor should not be logged in" do |_|
#   controller.logged_in?.should be_true
#   controller.current_user.login.should == "anonymous"
# end
#   
# Then "$actor should be logged in" do |_|
#   controller.logged_in?.should be_true
#   controller.current_user.login.should == @rites_login
# end
# 
# Then "$actor should be forwarded to their home page" do |_|
#   response.status.should == "200 OK"
#   response.body.should include("Welcome to RITES Investigations")
#   response.body.should match(/Welcome\n\s*#{@user.name}/)
# end
# 
# Then "$actor should be shown a helpful error message" do |_|
#   response.status.should == "200 OK"
#   response.body.should include("Login failed")
# end