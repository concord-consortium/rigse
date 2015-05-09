RailsPortal::Application.configure do
  # Edit at your own peril - it's recommended to regenerate this file
  # in the future when you upgrade to a newer version of Cucumber.

  # IMPORTANT: Setting config.cache_classes to false is known to
  # break Cucumber's use_transactional_fixtures method.
  # For more information see https://rspec.lighthouseapp.com/projects/16211/tickets/165
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local        = true
  config.action_controller.perform_caching  = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = {:protocol => APP_CONFIG[:protocol], :host => APP_CONFIG[:host] }
  # All the gems required for testing are listed in: config/environments/test.rb
  #
  # Install the gems required for testing:
  #
  #   sudo env RAILS_ENV=test rake gems:install
  #
  # The following are just the gems needed when running cucumber
  #
  config.active_support.deprecation = :stderr
  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  # Turn this off if localizing
  config.i18n.default_locale = 'en'
  config.i18n.fallbacks = true
end
