require File.expand_path('../../spec_helper', __FILE__)
describe SessionsController do

  fixtures        :users
  
  def do_create
    post :create, @login_params
  end
  
  before(:each) do
    generate_default_project_and_jnlps_with_mocks
    Admin::Project.stub!(:default_project).and_return(@mock_project)
    
    # This line prevented successful testing of a non-admin (eg, Student) user. -- Cantina-CMH 6/15/10
    #login_admin
    
    # 2011-11-08 NP: found ./lib/authenticated_test_helper.rb (this probably should be
    # moved!)
    @user  = mock_user
    @user.stub!(:require_password_reset).and_return(false)
    @login_params = { :login => 'quentin', :password => 'testpassword' }
    User.stub!(:authenticate).with(@login_params[:login], @login_params[:password]).and_return(@user)
    controller.stub!(:cookies).and_return(@login_params)
  end
  
  describe "on successful login," do
    [ [:nil,       nil,            nil],
    [:expired,   'valid_token',  15.minutes.ago],
    [:different, 'i_haxxor_joo', 15.minutes.from_now], 
    [:valid,     'valid_token',  15.minutes.from_now]
    ].each do |has_request_token, token_value, token_expiry|
      [ true, false ].each do |want_remember_me|
        describe "my request cookie token is #{has_request_token.to_s}," do
          describe "and ask #{want_remember_me ? 'to' : 'not to'} be remembered" do 
            before do
              @ccookies = mock('cookies')
              controller.stub!(:cookies).and_return(@ccookies)
              @ccookies.stub!(:[]).with(:auth_token).and_return(token_value)
              @ccookies.stub!(:delete).with(:auth_token)
              @ccookies.stub!(:[]=)
              @user.stub!(:require_password_reset).and_return(false)
              @user.stub!(:remember_me) 
              @user.stub!(:refresh_token) 
              @user.stub!(:forget_me)
              @user.stub!(:remember_token).and_return(token_value) 
              @user.stub!(:remember_token_expires_at).and_return(token_expiry)
              @user.stub!(:remember_token?).and_return(has_request_token == :valid)
              if want_remember_me
                @login_params[:remember_me] = '1'
              else 
                @login_params[:remember_me] = '0'
              end
            end

            it "kills existing login"        do 
              controller.should_receive(:logout_keeping_session!)
              do_create
            end    

            it "authorizes me"               do 
              do_create
              controller.send(:authorized?).should be_true
            end    

            it "logs me in"                  do 
              do_create
              controller.send(:logged_in?).should  be_true
            end    

            it "greets me nicely"            do 
              do_create
              response.flash[:notice].should =~ /success/i   
            end

            it "sets/resets/expires cookie"  do 
              controller.should_receive(:handle_remember_cookie!).with(want_remember_me)
              do_create
            end

            it "sends a cookie"              do 
              controller.should_receive(:send_remember_cookie!)
              do_create
            end

            it 'redirects to the home page'  do 
              do_create
              response.should redirect_to('/')
            end

            it "does not reset my session"   do 
              controller.should_not_receive(:reset_session).and_return nil
              do_create
            end # change if you uncomment the reset_session path

            if (has_request_token == :valid)
              it 'does not make new token'   do 
                @user.should_not_receive(:remember_me)
                do_create
              end
              it 'does refresh token'        do 
                @user.should_receive(:refresh_token)
                do_create
              end 
              it "sets an auth cookie"       do 
                do_create
              end

            else

              if want_remember_me

                it 'makes a new token'       do 
                  @user.should_receive(:remember_me)
                  do_create
                end 

                it "does not refresh token"  do
                  @user.should_not_receive(:refresh_token)
                  do_create
                end

                it "sets an auth cookie"       do
                  do_create
                end

              else 

                it 'does not make new token' do @user.should_not_receive(:remember_me)
                  do_create
                end

                it 'does not refresh token'  do @user.should_not_receive(:refresh_token)
                  do_create
                end 

                it 'kills user token'        do
                  @user.should_receive(:forget_me)
                  do_create
                end 
              end
            end
          end # inner describe
        end
      end
    end
      
    it "should not check for security questions if the user is not a student" do
      #@controller.stub!(:cookies).and_return({})
      @user.stub!(:remember_me) 
      @user.stub!(:refresh_token) 
      @user.stub!(:forget_me)
      @user.stub!(:remember_token)
      @user.stub!(:remember_token_expires_at)
      @user.stub!(:remember_token?)
      @login_params[:remember_me] = '0'
      
      @mock_project.should_receive(:use_student_security_questions).and_return(true)
      @user.should_receive(:portal_student).and_return(nil)
      @user.should_not_receive(:security_questions)
      
      do_create
      
      @response.should redirect_to(root_path)
    end
    
    describe "Student login" do
      before(:each) do
        User.destroy_all
        Portal::Student.destroy_all
        @login_params = { :login => 'grrrrrr', :password => 'testpassword' }
        @student = Factory.create(:portal_student, :user => Factory.create(:user, @login_params))
        User.stub!(:authenticate).with(@login_params[:login], @login_params[:password]).and_return(@student.user)
      end
      
      it "should not check for security questions if the current Admin::Project says not to" do
        @mock_project.should_receive(:use_student_security_questions).and_return(false)
        @student.user.should_not_receive(:security_questions)
        
        do_create
        
        @response.should redirect_to(root_path)
      end
      
      describe "Student with security questions" do
        it "should allow the student to log in normally" do
          questions = [
            true,
            true,
            true
          ]
          @mock_project.should_receive(:use_student_security_questions).and_return(true)
          @student.user.should_receive(:security_questions).and_return(questions)
          
          do_create
          
          @response.should redirect_to(root_path)
        end
      end
      
      describe "Student without security questions" do
        it "should redirect to the page where the student must set their security questions" do
          @mock_project.should_receive(:use_student_security_questions).and_return(true)
          @student.user.should_receive(:security_questions).and_return([])
          
          do_create
          
          @response.should redirect_to(edit_user_security_questions_path(@student.user))
        end
      end
    end
  end
  
  describe "on failed login" do
    before do
      User.should_receive(:authenticate).with(anything(), anything()).and_return(nil)
      login_as :quentin
    end
    it 'logs out keeping session'   do 
      controller.should_receive(:logout_keeping_session!)
      do_create
    end

    it 'flashes an error'           do
      do_create
      flash[:error].should =~ /Couldn't log you in as 'quentin'/
    end

    it 'renders the log in page'    do
      do_create
      response.should render_template('new')
    end

    it "doesn't log me in"          do
      pending "Broken example"
      do_create
      controller.send(:logged_in?).should == false
    end

    it "doesn't send password back" do
      @login_params[:password] = 'FROBNOZZ'
      do_create
      response.should_not have_text(/FROBNOZZ/i)
    end
  end

  describe "on signout" do
    def do_destroy
      get :destroy
    end
    before do 
      login_as :quentin
    end
    it 'logs me out'                   do 
      controller.should_receive(:logout_killing_session!)
      do_destroy 
    end

    it 'redirects me to the home page' do 
      do_destroy
      response.should be_redirect
    end
  end
  
end

describe SessionsController do
  describe "route generation" do
    it "should route the new sessions action correctly" do
      route_for(:controller => 'sessions', :action => 'new').should == "/login"
    end
    it "should route the create sessions correctly" do
      route_for(:controller => 'sessions', :action => 'create').should == {:path => "/session", :method => :post}
    end
    it "should route the destroy sessions action correctly" do
      route_for(:controller => 'sessions', :action => 'destroy').should == "/logout"
    end
  end
  
  describe "route recognition" do
    it "should generate params from GET /login correctly" do
      params_from(:get, '/login').should == {:controller => 'sessions', :action => 'new'}
    end
    it "should generate params from POST /session correctly" do
      params_from(:post, '/session').should == {:controller => 'sessions', :action => 'create'}
    end
    it "should generate params from DELETE /session correctly" do
      params_from(:delete, '/logout').should == {:controller => 'sessions', :action => 'destroy'}
    end
  end
  
  describe "named routing" do
    before(:each) do
      #get :new #FIXME: error
    end
    it "should route session_path() correctly" do
      pending "Broken example"
      session_path().should == "/session"
    end
    it "should route new_session_path() correctly" do
      pending "Broken example"
      new_session_path().should == "/session/new"
    end
  end
  
end
