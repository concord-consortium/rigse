class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :create
  
  def new
  end

  def create
    if cookies.blank?
      flash[:notice] = "Your browser does not have cookies enabled. Please refer to your browser's documentation to enable cookies."
      render :action => :new
    else
      logout_keeping_session!
      password_authentication
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(root_path)
  end

  def omniauth_check
    if params[:realm] && params[:realm_id] && params[:realm] == "user"
      if current_user == User.find_by_provider_and_uid(params[:provider], params[:realm_id])
        redirect_to(root_path)
        return
      end
    end
    redirect_to "/auth/#{params[:provider]}"
  end

  def omniauth_callback
    auth = request.env["omniauth.auth"]
    begin
      @user = User.find_by_provider_and_uid(auth["provider"], auth["uid"])
      if @user
        self.current_user = @user
        session[:original_user_id] = current_user.id
        flash[:notice] = "Logged in successfully"
        redirect_to(root_path) # unless !check_student_security_questions_ok
        return
      end

      # Handle email collisions! Merge accounts if password ok?
      @user = User.find_by_email(auth["info"]["email"])
      if @user
        @uid = auth["uid"]
        @provider = auth["provider"]
        render "link_account"
        return
      end

      @user = User.create_with_omniauth(auth)
      if @user
        self.current_user = @user
        session[:original_user_id] = current_user.id
        flash[:notice] = "Logged in successfully"

        @school_selector = Portal::SchoolSelector.new(params)
        render 'choose_school'
        return
      end
    rescue => e
      Rails.logger.warn "Error: #{e}\n\n#{e.backtrace.join("\n")}"
      redirect_to omniauth_failure_path
    end
  end

  def link_account
    @user = User.authenticate(params[:login], params[:password])
    @provider = params[:provider]
    @uid = params[:uid]
    if @user
      self.current_user = @user
      session[:original_user_id] = current_user.id
      @user.provider = @provider
      @user.uid = @uid
      if @user.save
        flash[:notice] = "Logged in successfully"
        redirect_to(root_path) # unless !check_student_security_questions_ok
      else
        flash[:error] = "Unable to link user accounts!"
      end
    else
      @user = User.find(params[:user_id])
      flash[:error] = "Invalid password!"
    end
  end

  def choose_school
    Rails.logger.warn "Entered choose_school"
    @user = current_user
    @school_selector = Portal::SchoolSelector.new(params)

    if @school_selector.valid?
      @portal_teacher = Portal::Teacher.create {|t|
        t.user = @user
        t.schools << @school_selector.school
      }
      redirect_to(root_path)
    else
      flash[:error] = "Please select a valid school."
      render
    end
  rescue
  end

  def omniauth_failure
  end

  protected
  
  def password_authentication
    user = User.authenticate(params[:login], params[:password])
    if user
      self.current_user = user
      session[:original_user_id] = current_user.id
      successful_login
    else
      note_failed_signin
      @login = params[:login]
      @remember_me = params[:remember_me]
      self.current_user = User.anonymous
      render :action => :new
    end
  end
  
  def successful_login
    new_cookie_flag = (params[:remember_me] == "1")
    handle_remember_cookie! new_cookie_flag
    flash[:notice] = "Logged in successfully"
    redirect_to(root_path) # unless !check_student_security_questions_ok
  end

  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
  
  # 2011-11-07 NP: moved to ApplicationController 
  # def check_student_security_questions_ok
  #   if current_project && current_project.use_student_security_questions && !current_user.portal_student.nil? && current_user.security_questions.size < 3
  #     redirect_to(edit_user_security_questions_path(current_user))
  #     return false
  #   end
  #   return true
  # end

end
