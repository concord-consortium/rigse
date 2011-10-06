class HelpRequestObserver < ActiveRecord::Observer
  def after_create(help_request)
    HelpRequestMailer.deliver_help_request_notification(help_request)
  end
end
