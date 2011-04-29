#
# Setup
#
Given "a valid sakai user" do
  @rinet_login = "bowb_dobs"
  @rites_login = ExternalUserDomain.external_login_to_login(@rinet_login)
  @user = Factory(:user, {
    :login => @rites_login
  });
  @user.register
  @user.activate
end

Given "an unknown sakai user" do
  @user_login = "someunknownuser"
  while User.first(:conditions => { :login => @user_login })
    @user_login << (rand * 100).to_i
  end
  @user = nil
end

#
# Actions
#
When "$actor goes to the link tool url" do |_|
  pending "Looks like signature for visit() has changed with capybara ... "
  visit('/linktool', :get, {:serverurl => "http://moleman.concord.org/", :internaluser => @rinet_login})
end

#
# Result
#
Then "$actor should not be logged in" do |_|
  controller.logged_in?.should be_true
  controller.current_user.login.should == "anonymous"
end
  
Then "$actor should be logged in" do |_|
  controller.logged_in?.should be_true
  controller.current_user.login.should == @rites_login
end

Then "$actor should be forwarded to their home page" do |_|
  response.status.should == "200 OK"
  response.body.should include("Welcome to RITES Investigations")
  response.body.should match(/Welcome\n\s*#{@user.name}/)
end

Then "$actor should be shown a helpful error message" do |_|
  response.status.should == "200 OK"
  response.body.should include("Login failed")
end