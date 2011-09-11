class PasswordMailer < ActionMailer::Base
  default :from => "Admin <#{APP_CONFIG[:help_email]}"
  
  def forgot_password(password)
    @user = password.user
    @url = "#{APP_CONFIG[:site_url]}/change_password/#{password.reset_code}"
    finish_email(password.user, 'You have requested to change your password')
  end

  def reset_password(user)
    @user = user
    finish_email(user, 'Your password has been reset.')
  end

  protected
  
  def finish_email(user, subject)
    # CHECKME: is this theme stuff necessary here?
    self.theme_name = (APP_CONFIG[:theme]||'default')
    mail(:to => "#{user.name} <#{user.email}>",
         :subject => "[#{APP_CONFIG[:site_name]}] #{subject}",
         :date => Time.now)
  end
end
