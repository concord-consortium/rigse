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
    self.current_visitor = User.find_by_login!(params[:username])
    head :ok
  end

  protected
  
  def password_authentication
    user = User.authenticate(params[:login], params[:password])
    if user
      if user.group_account_class_id
        # if it's outside of school hours, fail the login
        # TODO Can we adjust school hours based on the user's school's time zone?
        t = TZ[:eastern].utc_to_local(Time.now.utc)
        hour = t.hour
        if hour < current_project.school_start_hour || hour >= current_project.school_end_hour || t.saturday? || t.sunday?
          note_failed_signin_time_restriction
          @login = params[:login]
          @remember_me = params[:remember_me]
          self.current_visitor = User.anonymous
          redirect_to :home
          return
        end
      end
      self.current_visitor = user
      session[:original_user_id] = current_visitor.id
      successful_login
    else
      note_failed_signin
      @login = params[:login]
      @remember_me = params[:remember_me]
      self.current_visitor = User.anonymous
      redirect_to :home
    end
  end
  
  def successful_login
    new_cookie_flag = (params[:remember_me] == "1")
    handle_remember_cookie! new_cookie_flag
    flash[:notice] = "Logged in successfully"
    
    redirect_path = root_path
    
    if APP_CONFIG[:recent_activity_on_login] && current_visitor.portal_teacher
      portal_teacher = current_visitor.portal_teacher
      if (portal_teacher.teacher_clazzes.select{|tc| tc.active }).count > 0
        # Teachers with active classes are redirected to the "Recent Activity" page
        redirect_path = recent_activity_path
      end
    end
    
    redirect_to(redirect_path) # unless !check_student_security_questions_ok
  end

  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  def note_failed_signin_time_restriction
    flash[:error] = "The account '#{params[:login]}' is only allowed to log in during school hours (#{current_project.school_hours})"
  end
  # 2011-11-07 NP: moved to ApplicationController 
  # def check_student_security_questions_ok
  #   if current_project && current_project.use_student_security_questions && !current_visitor.portal_student.nil? && current_visitor.security_questions.size < 3
  #     redirect_to(edit_user_security_questions_path(current_visitor))
  #     return false
  #   end
  #   return true
  # end

  protected
  # authenticated system does this by default: 
  #def logged_in?
  #  !!current_visitor
  #end
  #
  # but out current_visitor will be 'anonymous'
  # because we always have a current_visitor
  def logged_in?
    return (!(current_visitor.nil? || current_visitor == User.anonymous))
  end
end
