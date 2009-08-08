# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rites_portal_session',
  :secret      => '924cdf373582bbc17ac32060921e6f028a996bb85bbb4b4d7d8cb8c98ef18615a793e676e511e0143708ee7c243c89605bcfdfaa339ed649e58e2fbd6498e117'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
