class Import::ImportedLoginController < ApplicationController

  def confirm_user
    user = User.find_by_login(session[:login])
    reset_password_via_email(user)
  end

  private

  def reset_password_via_email(user)
    password = Password.new(:user => user, :email => user.email)
    help_email = APP_CONFIG[:help_email] || APP_CONFIG[:admin_email] || APP_CONFIG[:default_admin_user][:email]
    write_to_us = "<a href=\"mailto:#{help_email}\">write to us</a> (#{help_email})"
    if password.save
      PasswordMailer.imported_password_reset(password).deliver
      flash[:alert] = "A link to change your password has been sent to <b>#{user.email}.</b><br>" +
                      "If you don't have access to this email address anymore, please #{write_to_us}."
    else
      flash[:error] = "This account has not set a valid email address. Please #{write_to_us} to access your account."
    end
  end
end
