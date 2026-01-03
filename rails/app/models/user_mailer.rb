class UserMailer < Devise::Mailer
  default :from => "Concord Consortium <#{APP_CONFIG[:help_email]}>"
  helper :theme

  def confirmation_instructions(record, token, opts={})
    @url = "#{APP_CONFIG[:site_url]}/activate/#{token}"
    @token = token
    @user = record
    finish_email(@user, "Activate your account on #{APP_CONFIG[:site_name]}")
  end

  protected

  def finish_email(user, subject)
    # Need to set the theme because normally it gets set in a controller before_action...
    mail(:to => "#{user.name} <#{user.email}>",
         :subject => subject,
         :date => Time.now)
  end
end
