class UserMailer < Devise::Mailer
  default :from => "#{APP_CONFIG[:site_name]} <#{APP_CONFIG[:help_email]}>"

  def confirmation_instructions(record, token, opts={})
    @url = "#{APP_CONFIG[:site_url]}/activate/#{token}"
    @token = token
    @user = record
    finish_email(@user, 'Please activate your new account')
  end

  protected

  def finish_email(user, subject)
    # Need to set the theme because normally it gets set in a controller before_filter...
    set_theme(APP_CONFIG[:theme]||'default')
    mail(:to => "#{user.name} <#{user.email}>",
         :subject => subject,
         :date => Time.now)
  end
end
