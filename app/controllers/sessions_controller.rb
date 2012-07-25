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

  # for cucumber testing only
  def backdoor
    logout_killing_session!
    self.current_user = User.find_by_login!(params[:username])
    head :ok
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
    
    redirect_path = root_path
    
    if current_user.portal_teacher
      # Teachers are redirected to the "Recent Activity" page
      redirect_path = recent_activity_path
    end
    
    redirect_to(redirect_path) # unless !check_student_security_questions_ok
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

  protected
  # authenticated system does this by default: 
  #def logged_in?
  #  !!current_user
  #end
  #
  # but out current_user will be 'anonymous'
  # because we always have a current_user
  def logged_in?
    return (!(current_user.nil? || current_user == User.anonymous))
  end
end
