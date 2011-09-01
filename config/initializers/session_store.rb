# Be sure to restart your server when you modify this file.

RailsPortal::Application.config.session_store :cookie_store, :key => '_rails_portal_session', :cookie_only => false
# allow session to be loaded from params. This is used so java
# connections can use the same session, specifically the config file

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")

RailsPortal::Application.config.session_store :active_record_store
