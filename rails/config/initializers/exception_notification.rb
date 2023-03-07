Rails.application.config.middleware.use ExceptionNotification::Rack,
  email: {
    deliver_with: :deliver, # Rails >= 4.2.1 do not need this option since it defaults to :deliver_now
    email_prefix: "[#{APP_CONFIG[:site_name]} Exception] ",
    sender_address: %("Application Error" <#{APP_CONFIG[:help_email]}>),
    exception_recipients: [%("Admin" <#{APP_CONFIG[:admin_email]}>)]
  }
