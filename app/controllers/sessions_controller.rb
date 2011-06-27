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
    delete_cc_cookie
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(root_path)
  end

  # verify a CC token
  def verify_cc_token
    begin
      token = cookies[CCCookieAuth.cookie_name]
      raise 'non-existent token' unless token
      valid = CCCookieAuth.verify_auth_token(token,request.remote_ip)
      raise 'invalid token' unless valid
      login = token.split(CCCookieAuth.token_separator).first
      raise 'token parse error' unless login
      user = User.find_by_login(login)
      riase 'bogus user' unless user
      values = {:login => login, :first => user.first_name, :last => user.last_name}
      student = user.portal_student
      teacher = user.portal_teacher
      if student
        values[:class_words] = student.clazzes.map{ |c| c.class_word }
        values[:teacher] = false
      end
      if teacher
        values[:class_words] = teacher.clazzes.map{ |c| c.class_word }
        values[:teacher] = true
      end
      render :json => values
    rescue Exception => e
      render :text => "authentication failure: #{e.message}", :status => 403
    end
  end
  
  # verify a remote login attempt
  def remote_login
    user = User.authenticate(params[:login], params[:password])
    if user
      self.current_user = user
      save_cc_cookie
      values = {:login => user.login, :first => user.first_name, :last => user.last_name}
      render :json => values
    else
      error = "authentication failure: invalid user or password"
      values = {:error => error}
      #render :text => error, :status => 403
      render :json => values, :status => 403
    end
  end

  # silently logout using a post request
  def remote_logout
    logout_killing_session!
    delete_cc_cookie
    message = "logged out."
    values = {:message => message}
    render :json => values
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
    save_cc_cookie
    flash[:notice] = "Logged in successfully"
    redirect_to(root_path) unless !check_student_security_questions_ok
  end

  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
  
  def check_student_security_questions_ok
    if current_project && current_project.use_student_security_questions && !current_user.portal_student.nil? && current_user.security_questions.size < 3
      redirect_to(edit_user_security_questions_path(current_user))
      return false
    end
    return true
  end

  def cookie_domain
    if defined? @cookie_domain
      return @cookie_domain
    end

    # use wildcard domain (last two parts ".concord.org") for this cookie
    @cookie_domain = request.host
    @cookie_domain = '.concord.org' if @cookie_domain =~ /\.concord\.org$/

    return @cookie_domain
  end

  def delete_cc_cookie
    #cookies.delete CCCookieAuth.cookie_name.to_sym
    if cookies.kind_of? ActionController::CookieJar
      cookies.delete(CCCookieAuth.cookie_name.to_sym, {:domain => cookie_domain})
    else
      cookies.delete CCCookieAuth.cookie_name.to_sym
    end
  end
  
  def save_cc_cookie
    token = CCCookieAuth.make_auth_token(current_user.login, request.remote_ip)
    #cookies[CCCookieAuth.cookie_name.to_sym] = token
    cookies[CCCookieAuth.cookie_name.to_sym] = {:value => token, :domain => cookie_domain }
  end

end
