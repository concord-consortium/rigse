class OidcMailer < ActionMailer::Base
  default :from => "#{APP_CONFIG[:site_name]} <#{APP_CONFIG[:help_email]}>"
  helper :theme

  def send_message(recipient_email, subject, message)
    @message = message
    mail(:to => recipient_email, :subject => subject, :date => Time.now)
  end
end
