class CustomFailure < Devise::FailureApp

  # Disable redirects (by redirecting to the current url) because of session timeouts.
  # Let the normal authentication rules force a redirect.
  def redirect
    store_location!
    message = warden.message || warden_options[:message]
    if message == :timeout
      redirect_to attempted_path
    else
      super
    end
  end

  def redirect_url
    root_path
  end

  # You need to override respond to eliminate recall
  def respond
    unless User.verified_ITSI_user?(params[:user][:login])
      redirect_to confirmation_user_itsi_login_path and return
    end
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
