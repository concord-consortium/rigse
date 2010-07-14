require 'spec_helper'

describe Investigation do
  before(:each) do
    @valid_attributes = {
      :name => "test investigation",
      :description => "new decription"
    }
  end

  it "should create a new instance given valid attributes" do
    Investigation.create!(@valid_attributes)
  end
  
  describe "should be publishable" do
    before(:each) do
      @investigation = Investigation.create!(@valid_attributes)
    end
    
    it "should not be public by default" do
      @investigation.published?.should be(false)
    end
    it "should be public if published" do
      @investigation.publish!
      @investigation.public?.should be(true)
    end
    
    it "should not be public if unpublished " do
      @investigation.publish!
      @investigation.public?.should be(true)
      @investigation.un_publish!
      @investigation.public?.should_not be(true)
    end
    
    it "should define a method for available_states" do
      @investigation.should respond_to(:available_states)
    end
  end
  
  describe "should be duplicateable" do
    before(:each) do
      @investigation = Investigation.create!(@valid_attributes)
      @user = Factory.create(:user, { :email => "test@test.com", :password => "password", :password_confirmation => "password" })
    end
    
    it "should not allow teachers to duplicate" do
      [:member, :guest].each do |role|
        @user.roles.destroy_all
        @user.add_role(role.to_s)
        
        @investigation.duplicateable?(@user).should be_false
      end
    end
    
    it "should allow admins, managers, etc. to duplicate" do
      [:admin, :manager, :researcher, :author].each do |role|
        @user.roles.destroy_all
        @user.add_role(role.to_s)
        
        @investigation.duplicateable?(@user).should be_true
      end
    end
  end
      
end
