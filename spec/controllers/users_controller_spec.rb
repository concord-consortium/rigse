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
    skip "Broken example"
    expect do
      create_user
      expect(response).to be_redirect
    end.to change(User, :count).by(1)
  end

  it 'signs up user in pending state' do
    skip "Broken example"
    create_user
    assigns(:user).reload
    expect(assigns(:user)).to be_pending
  end

  it 'signs up user with activation code' do
    skip "Broken example"
    create_user
    assigns(:user).reload
    expect(assigns(:user).activation_code).not_to be_nil
  end
  it 'requires login on signup' do
    skip "Broken example"
    expect do
      create_user(:login => nil)
      expect(assigns[:user].errors[:login]).not_to be_nil
      expect(response).to be_success
    end.not_to change(User, :count)
  end
  
  it 'requires password on signup' do
    skip "Broken example"
    expect do
      create_user(:password => nil)
      expect(assigns[:user].errors[:password]).not_to be_nil
      expect(response).to be_success
    end.not_to change(User, :count)
  end
  
  it 'requires password confirmation on signup' do
    skip "Broken example"
    expect do
      create_user(:password_confirmation => nil)
      expect(assigns[:user].errors[:password_confirmation]).not_to be_nil
      expect(response).to be_success
    end.not_to change(User, :count)
  end

  it 'requires email on signup' do
    skip "Broken example"
    expect do
      create_user(:email => nil)
      expect(assigns[:user].errors[:email]).not_to be_nil
      expect(response).to be_success
    end.not_to change(User, :count)
  end
  
  it 'activates user' do
    skip "Broken example"
    expect(User.authenticate('aaron', 'monkey')).to be_nil
    get :activate, :activation_code => users(:aaron).activation_code
    expect(response).to redirect_to('/login')
    expect(flash[:notice]).not_to be_nil
    expect(flash[:error ]).to     be_nil
    expect(User.authenticate('aaron', 'monkey')).to eq(users(:aaron))
  end
  
  it 'does not activate user without key' do
    skip "Broken example"
    get :activate
    expect(flash[:notice]).to     be_nil
    expect(flash[:error ]).not_to be_nil
  end
  
  it 'does not activate user with blank key' do
    skip "Broken example"
    get :activate, :activation_code => ''
    expect(flash[:notice]).to     be_nil
    expect(flash[:error ]).not_to be_nil
  end
  
  it 'does not activate user with bogus key' do
    skip "Broken example"
    get :activate, :activation_code => 'i_haxxor_joo'
    expect(flash[:notice]).to     be_nil
    expect(flash[:error ]).not_to be_nil
  end
  
  it 'shows thank you page to teacher on successful registration' do
    
    get :registration_successful, {:type => 'teacher'}
    
    expect(@response).to render_template("users/thanks")
    
    assert_select 'h2', /thanks/i
    assert_select 'p', /activation code/i
    
  end
  
  it 'shows thank you page to the student with login name on successful registration' do
    
    get :registration_successful, {:type => 'student'}
    
    expect(@response).to render_template("portal/students/signup_success")
    
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
