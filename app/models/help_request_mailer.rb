class HelpRequestMailer < ActionMailer::Base
  def help_request_notification(help_request)
    setup_email(help_request)
  end
  
  protected
  
  def setup_email(help_request)
    self.current_theme = (APP_CONFIG[:theme]||'default')
    @recipients = "itsisu-support@concord.org"
    @from = "#{APP_CONFIG[:site_name]} <#{APP_CONFIG[:help_email]}>"
    @subject = "New Help Request from #{help_request.name}"
    @sent_on = Time.now
    @body[:url] = "#{APP_CONFIG[:site_url]}/help_requests/#{help_request.id}"
    @body[:help_request] = help_request
  end
end