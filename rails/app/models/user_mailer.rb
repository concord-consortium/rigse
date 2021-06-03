class UserMailer < Devise::Mailer
  default :from => "#{APP_CONFIG[:site_name]} <#{APP_CONFIG[:help_email]}>"
  helper :theme

  def confirmation_instructions(record, token, opts={})
    @url = "#{APP_CONFIG[:site_url]}/activate/#{token}"
    @token = token
    @user = record
    finish_email(@user, 'Please activate your new account')
  end

  # TODO: NP 2020-08-11 Methods removed as per  https://bit.ly/2PJlnG5
  # I have some anxiety about removing them:

  # def signup_notification(user)
  #   @url = "#{APP_CONFIG[:site_url]}/activate/#{user.confirmation_token}"
  #   @user = user
  #   finish_email(user, 'Please activate your new account')
  # end

  # def activation(user)
  #   @url = APP_CONFIG[:site_url]
  #   @user = user
  #   finish_email(user, 'Your account has been activated!')
  # end

  protected

  def finish_email(user, subject)
    # Need to set the theme because normally it gets set in a controller before_action...
    mail(:to => "#{user.name} <#{user.email}>",
         :subject => subject,
         :date => Time.now)
  end
end
