class SessionsController < Devise::SessionsController
  # With Rails 3 and Devise there doesn't seem to be a good way to handle an invalid
  # token. The session is cleared and then the login actually continues, but with
  # mostly empty session.  In more recent Rails the authenticity token can be setup to
  # throw an exception. If it threw that exception then the login should stop and the
  # the user could see an error message.
  # In the meantime we'll disable the authenticity token check on login.
  skip_before_filter :verify_authenticity_token, :only => [:create]

  def new
    super
  end
end
