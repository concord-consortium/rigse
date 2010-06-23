require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Portal::Student do
  before(:each) do
    @student = Factory(:portal_student)
  end
  
  describe "when a clazz is added to a students list of clazzes" do
    it "the students clazz list increases by one if the student is not already enrolled in that class" do
      clazz = Factory(:portal_clazz)
      @student.clazzes.should be_empty
      @student.add_clazz(clazz)
      @student.reload
      @student.clazzes.should_not be_empty
      @student.clazzes.should include(clazz)
      @student.should have(1).clazzes
    end
    
    it "the students clazz list should stay the same if the same clazz is added multiple times" do
      clazz = Factory(:portal_clazz)
      @student.clazzes.should be_empty
      @student.add_clazz(clazz)
      @student.add_clazz(clazz)
      @student.reload
      @student.clazzes.should_not be_empty
      @student.clazzes.should include(clazz)
      @student.should have(1).clazzes
    end
  end
  
  it "should generate a user name by first initial and last name" do
    Portal::Student.generate_user_login("test", "user").should == "tuser"
    
    first_name = "Nametest"
    last_name  = "Testuser"
    @student.user = Factory.create(:user, {
      :first_name => first_name,
      :last_name => last_name,
      :login => Portal::Student.generate_user_login(first_name, last_name),
      :password => "password",
      :password_confirmation => "password",
      :email => "test@test.com"
    })
    @student.user.login.should == "ntestuser"
    Portal::Student.generate_user_login(@student.first_name, @student.last_name).should == @student.user.login + "2"
  end

end
