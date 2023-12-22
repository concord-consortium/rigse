# Be sure to restart your server when you modify this file.

# the key used to be _bort_session in the rails2 version of this app

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")

# For testing environments, we don't use SSL and can't set cookie to secure.
secure = !(Rails.env.development? || Rails.env.cucumber? || Rails.env.test? || Rails.env.feature_test?)
RailsPortal::Application.config.session_store :active_record_store, :key => '_rails_portal_session', secure: secure
