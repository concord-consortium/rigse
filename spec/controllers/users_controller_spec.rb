require File.expand_path('../../spec_helper', __FILE__)
describe UsersController do
  fixtures :users
  fixtures :roles
  
  render_views
  
  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
    logout_user
  end

  it 'allows signup' do
    pending "Broken example"
    lambda do
      create_user
      response.should be_redirect
    end.should change(User, :count).by(1)
  end

  it 'signs up user in pending state' do
    pending "Broken example"
    create_user
    assigns(:user).reload
    assigns(:user).should be_pending
  end

  it 'signs up user with activation code' do
    pending "Broken example"
    create_user
    assigns(:user).reload
    assigns(:user).activation_code.should_not be_nil
  end
  it 'requires login on signup' do
    pending "Broken example"
    lambda do
      create_user(:login => nil)
      assigns[:user].errors[:login].should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password on signup' do
    pending "Broken example"
    lambda do
      create_user(:password => nil)
      assigns[:user].errors[:password].should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password confirmation on signup' do
    pending "Broken example"
    lambda do
      create_user(:password_confirmation => nil)
      assigns[:user].errors[:password_confirmation].should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires email on signup' do
    pending "Broken example"
    lambda do
      create_user(:email => nil)
      assigns[:user].errors[:email].should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'activates user' do
    pending "Broken example"
    User.authenticate('aaron', 'monkey').should be_nil
    get :activate, :activation_code => users(:aaron).activation_code
    response.should redirect_to('/login')
    flash[:notice].should_not be_nil
    flash[:error ].should     be_nil
    User.authenticate('aaron', 'monkey').should == users(:aaron)
  end
  
  it 'does not activate user without key' do
    pending "Broken example"
    get :activate
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
  
  it 'does not activate user with blank key' do
    pending "Broken example"
    get :activate, :activation_code => ''
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
  
  it 'does not activate user with bogus key' do
    pending "Broken example"
    get :activate, :activation_code => 'i_haxxor_joo'
    flash[:notice].should     be_nil
    flash[:error ].should_not be_nil
  end
  
  it 'shows thank you page to teacher on successful registration' do
    
    get :registration_successful, {:type => 'teacher'}
    
    @response.should render_template("users/thanks")
    
    assert_select 'h2', /thanks/i
    assert_select 'p', /activation code/i
    
  end
  
  it 'shows thank you page to the student with login name on successful registration' do
    
    get :registration_successful, {:type => 'student'}
    
    @response.should render_template("portal/students/signup_success")
    
    # should show text "your username is"
    assert_select "p", /username\s+is/i
    
    # should show directions to login:
    assert_select 'p', /login/i
    
    assert_select "*#clazzes_nav", false
    assert_select "input#header_login"
    
    
    assert_nil flash[:error]
    assert_nil flash[:notice]
  end
  
  
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
  end
  
  
  
end
