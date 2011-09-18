# Be sure to restart your server when you modify this file.

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
RailsPortal::Application.config.session_store :active_record_store, 

  # this used to be _bort_session in the rails2 version of this app
  :key => '_rails_portal_session', 
  
  # allow session to be loaded from params. This is used so java
  # connections can use the same session, specifically the config file
  :cookie_only => false
