class ExternalSessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :create
  
  def new
  end

  def create
    logout_keeping_session!
    password_authentication
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(root_path)
  end

  protected
  
  def password_authentication
    user = User.authenticate(params[:login], params[:password])
    if user
      self.current_visitor = user
      session[:original_user_id] = current_visitor.id
      successful_login
    else
      note_failed_signin
      @login = params[:login]
      @remember_me = params[:remember_me]
      self.current_visitor = User.anonymous
      render :action => :new
    end
  end
  
  def successful_login
    new_cookie_flag = (params[:remember_me] == "1")
    handle_remember_cookie! new_cookie_flag
    redirect_to(root_path)
    flash[:notice] = "Logged in successfully"
  end

  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
