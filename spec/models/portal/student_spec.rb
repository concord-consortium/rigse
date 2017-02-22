require File.expand_path('../../../spec_helper', __FILE__)

describe Portal::Student do
  before(:each) do
    @student = Factory(:portal_student)
  end
  
  describe "when a clazz is added to a students list of clazzes" do
    it "the students clazz list increases by one if the student is not already enrolled in that class" do
      clazz = Factory(:portal_clazz)
      expect(@student.clazzes).to be_empty
      @student.add_clazz(clazz)
      @student.reload
      expect(@student.clazzes).not_to be_empty
      expect(@student.clazzes).to include(clazz)
      expect(@student.clazzes.size).to eq(1)
    end
    
    it "the students clazz list should stay the same if the same clazz is added multiple times" do
      clazz = Factory(:portal_clazz)
      expect(@student.clazzes).to be_empty
      @student.add_clazz(clazz)
      @student.add_clazz(clazz)
      @student.reload
      expect(@student.clazzes).not_to be_empty
      expect(@student.clazzes).to include(clazz)
      expect(@student.clazzes.size).to eq(1)
    end
  end
  
  it "should generate a user name by first initial and last name" do
    expect(Portal::Student.generate_user_login("test", "user")).to eq("tuser")
    
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
    expect(@student.user.login).to eq("ntestuser")
    expect(Portal::Student.generate_user_login(@student.first_name, @student.last_name)).to eq(@student.user.login + "1")
  end

end
