class Import::ImportedLoginController < ApplicationController

  def confirm_user
    user = User.find_by_login(session[:login])
    reset_password_via_email(user)
  end

  private

  def reset_password_via_email(user)
    password = Password.new(:user => user, :email => user.email) # strong params not required
    help_email = APP_CONFIG[:help_email] || APP_CONFIG[:admin_email] || APP_CONFIG[:default_admin_user][:email]
    write_to_us = "<a href=\"mailto:#{help_email}\">write to us</a> (#{help_email})"
    if password.save
      PasswordMailer.imported_password_reset(password).deliver
      flash['alert'] = "Your account was imported. A link to set your password has been sent to: <b>#{user.email}.</b><br>" +
                      "If you need help, #{write_to_us}."
    else
      flash['error'] = "Your account was imported from another site. We need a valid email address to complete the " +
                      "import process, and your account does not have one. Please #{write_to_us} to access your account."
    end
  end

  # STRONG_PARAMS_REVIEW: model attr_accessible didn't match model attributes:
  #  attr_accessible: :email, :user, :user_id
  #  model attrs:     :expiration_date, :reset_code, :user_id
  def password_strong_params(params)
    params.permit(:expiration_date, :reset_code, :user_id)
  end
end
