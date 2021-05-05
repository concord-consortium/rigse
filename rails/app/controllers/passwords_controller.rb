class PasswordsController < ApplicationController
  def login
    @user_login = User.new
  end

  def questions
    @user_recovery = User.find(params[:user_id])
  end

  def check_questions
    @user_check_questions = User.find(params[:user_id])
    questions = params[:security_questions]

    ok = 0
    questions.each do |k, v|
      ok += 1 if @user_check_questions.security_questions.find(v[:id]).answer.downcase == v[:answer].to_s.downcase
    end

    if ok == 3
      # success!
      @password = Password.new(:user => @user_check_questions, :email => @user_check_questions.email)
      if @password.save
        redirect_to change_password_path(@password.reset_code)
        return
      end
    end

    # TODO: limit the number of wrong attempts for a single user
    flash['error'] = "Sorry, you did not answer all of your questions correctly."
    redirect_to password_questions_path(@user_check_questions.id)
  end

  def reset
    @user_reset_password = find_password_user
  end

  def update_users_password
    if params[:commit] == "Cancel"
      redirect_to session[:return_to] || root_path
      return
    end

    @user_reset_password = find_password_user
    @user_reset_password.password = params[:user_reset_password][:password]
    @user_reset_password.password_confirmation = params[:user_reset_password][:password_confirmation]
    @user_reset_password.updating_password = true
    @user_reset_password.save

    if @user_reset_password.errors.empty?
      flash['notice'] = "Password for #{@user_reset_password.login} was successfully updated."
      @user_reset_password.require_password_reset=false
      @user_reset_password.save

      imported_user = @user_reset_password.imported_user
      if imported_user
        imported_user.is_verified = true unless imported_user.is_verified
        imported_user.save
      end

      if @user_reset_password.id == current_visitor.id
        #re-sign-in user
        sign_in @user_reset_password, :bypass => true
      end
      redirect_to(session[:return_to] || root_path)
    else
      # flash['error'] = 'Password could not be updated'
      # redirect_to :action => :reset, :reset_code => params[:reset_code], :user_errors => @user.errors
      render 'reset'
    end
  end

  def update
    @password = Password.find(params[:id])
    if @password.update_attributes(password_strong_params(params[:password]))
      flash['notice'] = 'Password was successfully updated.'
      redirect_back_or activities_url
    else
      render :action => :edit
    end
  end

  protected

  def find_password_user
    return current_visitor if params[:reset_code] == "0" && !current_visitor.anonymous?
    begin
      @user_find = Password.where('reset_code = ? and expiration_date > ?', params[:reset_code], Time.now).first.user
      return @user_find
    rescue
      flash['notice'] = 'The change password URL you visited is either invalid or expired.'
      redirect_to root_path
    end
  end

  def password_strong_params(params)
    # Changed to test for tighter parameter check - the commented out line is the old attr_accessible items
    # params && params.permit(:email, :user, :user_id)
    params && params.permit(:email)
  end
end
