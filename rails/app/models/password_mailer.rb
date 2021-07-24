class PasswordMailer < ActionMailer::Base
  default :from => "#{APP_CONFIG[:site_name]} <#{APP_CONFIG[:help_email]}>"
  helper :theme
  def forgot_password(password)
    @user = password.user
    @url = "#{APP_CONFIG[:site_url]}/change_password/#{password.reset_code}"
    finish_email(password.user, 'You have requested to change your password')
  end

  def reset_password(user)
    @user = user
    finish_email(user, 'Your password has been reset.')
  end

  def imported_password_reset(password)
    @user = password.user
    @url = "#{APP_CONFIG[:site_url]}/change_password/#{password.reset_code}"
    finish_email(password.user, "Welcome to the #{APP_CONFIG[:site_name]}", APP_CONFIG[:admin_email])
  end

  protected

  def finish_email(user, subject, bcc=nil)
    mail(:to => "#{user.name} <#{user.email}>",
         :subject => subject,
         :bcc => [bcc],
         :date => Time.now)
  end
end
