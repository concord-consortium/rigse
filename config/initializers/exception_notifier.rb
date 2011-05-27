ExceptionNotifier.exception_recipients = APP_CONFIG[:admin_email]
ExceptionNotifier.sender_address = %("Application Error" <#{APP_CONFIG[:help_email]}>)
