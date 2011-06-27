require File.expand_path('../../spec_helper', __FILE__)

describe ExternalUserDomain do

  it "should add the external_domain_suffix to a sakai login when generating a valid rites login" do
    ExternalUserDomain.external_login_to_login("mylogin").should 
      eql("mylogin_#{ExternalUserDomain.external_domain_suffix}")
  end

  it "should replace special characters in a sakai login with underscores when generating a valid rites login" do
    ExternalUserDomain.external_login_to_login("le`Chat Mc'Donald (not the dog)").should
      eql("le_Chat_Mc_Donald_not_the_dog_#{ExternalUserDomain.external_domain_suffix}")
  end
  
  it "should map to external forms and from internal forms consistently" do
    external_logins = ["bubba","b_u_bba","bubba","_bubba","bubba_"]
    external_logins.each do |external_login|
      internal_login = ExternalUserDomain.external_login_to_login(external_login)
      internal_login.should_not eql(external_login)
      ExternalUserDomain.login_to_external_login(internal_login).should eql(external_login)
    end
  end
  # possibly useful tests later if the code is refactored to use instance models ...
  #
  # before(:each) do
  #   @external_user_domain = Factory(:external_user_domain)
  #   @valid_attributes = {
  #     :name => "test sakai",
  #     :description => "a test domain representing an external; sakai instance",
  #     :server_url => "http://sakai-server.edu",
  #   }    
  # end
  # 
  # it "should create a new instance given valid attributes" do
  #   ExternalUserDomain.create(@valid_attributes).should be_valid
  # end
  # 
  # it "should not create a new instance given an invalid server_url" do
  #   invalid_attributes = @valid_attributes
  #   invalid_attributes[:server_url] = "ftp://sakai-server.edu"
  #   ExternalUserDomain.new(invalid_attributes).should_not be_valid
  # end
  # 
  # it "should not create a new instance given an empty name" do
  #   invalid_attributes = @valid_attributes
  #   invalid_attributes[:name] = ""
  #   ExternalUserDomain.new(invalid_attributes).should_not be_valid
  # end
  # 
  # it "should create valid users" do
  #   existing_users = User.find(:all)
  #   params = {
  #     :login  => "boo",
  #     :password => "password",
  #     :password_confirmation => "password",
  #     :first_name => "boo",
  #     :last_name  => "boo",
  #     :email => "knowuh@gmail.com"
  #   }
  #   user = ExternalUserDomain.create_user_with_external_login(params)
  #   user.should be_kind_of User
  #   user.id.should_not be_nil
  #   user.should be_valid
  #   existing_users.size.should be < User.find(:all).size
  # end
  # 
  # it "should find valid users" do
  #   params = {
  #      :login  => "boo",
  #      :password => "password",
  #      :password_confirmation => "password",
  #      :first_name => "boo",
  #      :last_name  => "boo",
  #      :email => "knowuh@gmail.com"
  #    }
  #    user = ExternalUserDomain.create_user_with_external_login(params)
  #    found_user = ExternalUserDomain.find_user_by_external_login('boo')
  #    found_user.should eql(user)
  # end
  
end
