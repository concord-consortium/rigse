class UserMailer < Devise::Mailer
  default :from => "Admin <#{APP_CONFIG[:help_email]}>"
  
  def confirmation_instructions(record, opts={})
  end
  
  def signup_notification(user)
    @url = "#{APP_CONFIG[:site_url]}/activate/#{user.confirmation_token}"
    @user = user
    finish_email(user, 'Please activate your new account')
  end
  
  def activation(user)
    @url = APP_CONFIG[:site_url]
    @user = user
    finish_email(user, 'Your account has been activated!')
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
