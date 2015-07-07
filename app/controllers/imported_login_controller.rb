class ImportedLoginController < ApplicationController

  def confirm_user
  end

  def imported_user_validation
    user = User.find_by_login(params[:login])

    unless user
      flash[:error] = 'Invalid username.'
      invalid_user and return
    end

    if User.verified_imported_user?(params[:login])
      flash[:error] = 'Invalid username.'
      invalid_user
    end

    if user.school && user.school.country
      country = user.school.country
      if params[:country] == "United States"
      	if params[:state] == user.school.state
          sign_in_user(user)
        else
          flash[:error] = 'Invalid username, country or state.'
          invalid_user
        end
      elsif country && params[:country] == country.name
        sign_in_user(user)
      else
      	flash[:error] = 'Invalid username or country.'
        invalid_user
      end
    else
      flash[:error] = "Please contact Portal administrator at <a href='mailto:#{APP_CONFIG[:help_email]}'>#{APP_CONFIG[:help_email]}</a> to reset your password."
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

end
