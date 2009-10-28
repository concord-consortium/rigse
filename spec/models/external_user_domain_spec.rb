require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ExternalUserDomain do
  
  before(:each) do
    @external_user_domain = Factory(:external_user_domain)
    @valid_attributes = {
      :name => "test sakai",
      :description => "a test domain representing an external; sakai instance",
      :server_url => "http://sakai-server.edu",
    }    
  end

  it "should create a new instance given valid attributes" do
    ExternalUserDomain.create(@valid_attributes).should be_valid
  end

  it "should not create a new instance given an invalid server_url" do
    invalid_attributes = @valid_attributes
    invalid_attributes[:server_url] = "ftp://sakai-server.edu"
    ExternalUserDomain.new(invalid_attributes).should_not be_valid
  end

  it "should not create a new instance given an empty name" do
    invalid_attributes = @valid_attributes
    invalid_attributes[:name] = ""
    ExternalUserDomain.new(invalid_attributes).should_not be_valid
  end

  it "should create valid users" do
   params = {
      :login  => "boo",
      :password => "password",
      :password_confirmation => "password",
      :first_name => "boo",
      :last_name  => "boo",
      :email => "knowuh@gmail.com"
    }
    user = ExternalUserDomain.create_user_with_external_login(params)
    user.should be_kind_of User
    user.id.should_not be_nil
    user.should be_valid
  end
  
  it "should find valid users" do
    params = {
       :login  => "boo",
       :password => "password",
       :password_confirmation => "password",
       :first_name => "boo",
       :last_name  => "boo",
       :email => "knowuh@gmail.com"
     }
     user = ExternalUserDomain.create_user_with_external_login(params)
     found_user = ExternalUserDomain.find_user_by_external_login("boo")
     found_user.should eql user
  end
  
end
