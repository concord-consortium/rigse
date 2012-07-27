RailsPortal::Application.config.middleware.use ExceptionNotifier,
  :email_prefix => "[#{APP_CONFIG[:site_name]} Exception] ",
  :sender_address => %("Application Error" <#{APP_CONFIG[:help_email]}>),
  :exception_recipients => [%("Admin" <#{APP_CONFIG[:admin_email]}>)]
