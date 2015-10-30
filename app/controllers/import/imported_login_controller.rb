class Import::ImportedLoginController < ApplicationController

  def confirm_user
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Import::ImportedLogin
    # authorize @imported_login
    # authorize Import::ImportedLogin, :new_or_create?
    # authorize @imported_login, :update_edit_or_destroy?
  end

  def imported_user_validation
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Import::ImportedLogin
    # authorize @imported_login
    # authorize Import::ImportedLogin, :new_or_create?
    # authorize @imported_login, :update_edit_or_destroy?
    user = User.find_by_login(params[:login])

    unless user
      flash[:error] = 'Invalid username.'
      invalid_user and return
    end

    if User.verified_imported_user?(params[:login])
      flash[:error] = 'Invalid username.'
      invalid_user and return
    end

    if user.school && user.school.country
      country = user.school.country
      if params[:country] == "United States"
      	if params[:state] == user.school.state
          sign_in_user(user)
        else
          send_mail(user, "You have entered an invalid country or state.")
          #flash[:error] = 'Invalid country or state.'
          invalid_user
        end
      elsif country && params[:country] == country.name
        sign_in_user(user)
      else
        send_mail(user, "You have entered an invalid country.")
      	#flash[:error] = 'Invalid country.'
        invalid_user
      end
    else
      send_mail(user, nil)
      #flash[:error] = "Please contact Portal administrator at <a href='mailto:#{APP_CONFIG[:help_email]}'>#{APP_CONFIG[:help_email]}</a> to reset your password."
      invalid_user
    end
  end

  private

  def sign_in_user(user)
    sign_in user
    redirect_to change_password_path(:reset_code => '0')
  end

  def invalid_user
  	redirect_to :action => 'confirm_user'
  end

  def send_mail(user, message)
    @password = Password.new(:user => user, :email => user.email)
    if @password.save
      PasswordMailer.imported_password_reset(@password).deliver
      message = "<p>#{message}<p><p>Your account activation has been sent to your email address. Please check your email and click the link you find there from ITSI.</p>"
    else
      flash[:error] = "This account has not set a valid email address. Please contact your school manager to access your account."
    end
    flash[:alert] = message
  end

end
